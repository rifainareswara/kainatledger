import uuid
from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import ForbiddenException, NotFoundException
from app.models.wallet import Wallet
from app.schemas.wallet import WalletCreate, WalletResponse, WalletSummaryResponse, WalletUpdate


def _to_response(wallet: Wallet) -> WalletResponse:
    return WalletResponse(
        id=str(wallet.id),
        name=wallet.name,
        type=wallet.type,
        balance=str(wallet.balance),
        currency=wallet.currency,
        color=wallet.color,
        icon=wallet.icon,
        is_active=wallet.is_active,
    )


async def list_wallets(db: AsyncSession, user_id: uuid.UUID) -> list[WalletResponse]:
    rows = await db.scalars(
        select(Wallet)
        .where(Wallet.user_id == user_id, Wallet.is_active.is_(True))
        .order_by(Wallet.name)
    )
    return [_to_response(w) for w in rows.all()]


async def get_wallet_summary(db: AsyncSession, user_id: uuid.UUID) -> WalletSummaryResponse:
    rows = await db.scalars(
        select(Wallet).where(Wallet.user_id == user_id, Wallet.is_active.is_(True))
    )
    wallets = rows.all()
    total = sum(w.balance for w in wallets)
    return WalletSummaryResponse(
        total_balance=str(total),
        currency="IDR",
        wallet_count=len(wallets),
        wallets=[_to_response(w) for w in wallets],
    )


async def get_wallet(
    db: AsyncSession, user_id: uuid.UUID, wallet_id: uuid.UUID
) -> WalletResponse:
    wallet = await _get_owned(db, user_id, wallet_id)
    return _to_response(wallet)


async def create_wallet(
    db: AsyncSession, user_id: uuid.UUID, data: WalletCreate
) -> WalletResponse:
    wallet = Wallet(
        user_id=user_id,
        name=data.name,
        type=data.type,
        balance=data.initial_balance,
        currency=data.currency,
        color=data.color,
        icon=data.icon,
    )
    db.add(wallet)
    await db.commit()
    await db.refresh(wallet)
    return _to_response(wallet)


async def update_wallet(
    db: AsyncSession,
    user_id: uuid.UUID,
    wallet_id: uuid.UUID,
    data: WalletUpdate,
) -> WalletResponse:
    wallet = await _get_owned(db, user_id, wallet_id)
    if data.name is not None:
        wallet.name = data.name
    if data.color is not None:
        wallet.color = data.color
    if data.icon is not None:
        wallet.icon = data.icon
    await db.commit()
    await db.refresh(wallet)
    return _to_response(wallet)


async def deactivate_wallet(
    db: AsyncSession, user_id: uuid.UUID, wallet_id: uuid.UUID
) -> None:
    wallet = await _get_owned(db, user_id, wallet_id)
    wallet.is_active = False
    await db.commit()


async def _get_owned(
    db: AsyncSession, user_id: uuid.UUID, wallet_id: uuid.UUID
) -> Wallet:
    wallet = await db.get(Wallet, wallet_id)
    if not wallet or not wallet.is_active:
        raise NotFoundException("Wallet")
    if wallet.user_id != user_id:
        raise ForbiddenException()
    return wallet
