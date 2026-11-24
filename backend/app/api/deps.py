import uuid
from typing import AsyncGenerator, Optional

from fastapi import Depends, Header
from jose import JWTError
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import CredentialsException
from app.core.security import decode_access_token
from app.db.session import get_db
from app.models.user import User


async def get_current_user(
    authorization: Optional[str] = Header(None, alias="Authorization"),
    db: AsyncSession = Depends(get_db),
) -> User:
    if not authorization or not authorization.startswith("Bearer "):
        raise CredentialsException("Missing or invalid authorization header")

    token = authorization.removeprefix("Bearer ").strip()
    try:
        user_id: uuid.UUID = decode_access_token(token)
    except (JWTError, ValueError):
        raise CredentialsException()

    user = await db.scalar(select(User).where(User.id == user_id))
    if not user:
        raise CredentialsException("User not found")
    if not user.is_active:
        raise CredentialsException("Account is deactivated")
    return user
