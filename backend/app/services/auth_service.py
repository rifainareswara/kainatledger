import uuid
from datetime import datetime, timezone

from fastapi import Request
from jose import JWTError
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import CredentialsException, ConflictException
from app.core.security import (
    create_access_token,
    generate_refresh_token,
    hash_password,
    verify_password,
    verify_refresh_token_hash,
    decode_access_token,
)
from app.models.user import RefreshToken, User
from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse, AccessTokenResponse


async def register_user(db: AsyncSession, data: RegisterRequest) -> User:
    existing = await db.scalar(select(User).where(User.email == data.email))
    if existing:
        raise ConflictException("Email already registered")

    user = User(
        email=data.email,
        full_name=data.full_name.strip(),
        hashed_password=hash_password(data.password),
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    from app.services.category_service import seed_default_categories
    await seed_default_categories(db, user.id)

    return user


async def login_user(
    db: AsyncSession, data: LoginRequest, request: Request
) -> TokenResponse:
    user = await db.scalar(select(User).where(User.email == data.email))
    if not user or not verify_password(data.password, user.hashed_password):
        raise CredentialsException("Invalid email or password")
    if not user.is_active:
        raise CredentialsException("Account is deactivated")

    access_token = create_access_token(user.id)
    raw_refresh, token_hash, expires_at = generate_refresh_token()

    db.add(
        RefreshToken(
            user_id=user.id,
            token_hash=token_hash,
            expires_at=expires_at,
            user_agent=request.headers.get("user-agent", "")[:255],
        )
    )
    await db.commit()

    from app.core.config import settings

    return TokenResponse(
        access_token=access_token,
        refresh_token=raw_refresh,
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


async def refresh_tokens(db: AsyncSession, raw_token: str) -> AccessTokenResponse:
    # Find a non-revoked, non-expired token matching the hash
    now = datetime.now(timezone.utc)
    tokens = await db.scalars(
        select(RefreshToken).where(
            RefreshToken.is_revoked.is_(False),
            RefreshToken.expires_at > now,
        )
    )
    matched: RefreshToken | None = None
    for rt in tokens:
        if verify_refresh_token_hash(raw_token, rt.token_hash):
            matched = rt
            break

    if not matched:
        raise CredentialsException("Invalid or expired refresh token")

    # Rotate: revoke old, issue new access token
    await db.execute(
        update(RefreshToken)
        .where(RefreshToken.id == matched.id)
        .values(is_revoked=True)
    )
    await db.commit()

    from app.core.config import settings

    access_token = create_access_token(matched.user_id)
    return AccessTokenResponse(
        access_token=access_token,
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


async def logout_user(db: AsyncSession, user_id: uuid.UUID, raw_token: str) -> None:
    tokens = await db.scalars(
        select(RefreshToken).where(
            RefreshToken.user_id == user_id,
            RefreshToken.is_revoked.is_(False),
        )
    )
    for rt in tokens:
        if verify_refresh_token_hash(raw_token, rt.token_hash):
            await db.execute(
                update(RefreshToken)
                .where(RefreshToken.id == rt.id)
                .values(is_revoked=True)
            )
    await db.commit()


async def logout_all(db: AsyncSession, user_id: uuid.UUID) -> None:
    await db.execute(
        update(RefreshToken)
        .where(RefreshToken.user_id == user_id, RefreshToken.is_revoked.is_(False))
        .values(is_revoked=True)
    )
    await db.commit()
