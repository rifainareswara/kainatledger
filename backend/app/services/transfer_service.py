import math
import uuid
from datetime import date as date_type, datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.exceptions import ForbiddenException, InsufficientBalanceException, NotFoundException
from app.models.category import Category
from app.models.transaction import Transaction
from app.models.transfer import Transfer
from app.models.wallet import Wallet
from app.schemas.transfer import (
    TransferCreate,
    TransferListResponse,
    TransferResponse,
    WalletBrief,
)


def _to_response(transfer: Transfer) -> TransferResponse:
    return TransferResponse(
        id=str(transfer.id),
        from_wallet=WalletBrief(
            id=str(transfer.from_wallet.id),
            name=transfer.from_wallet.name,
            balance=str(transfer.from_wallet.balance),
        ),
        to_wallet=WalletBrief(
            id=str(transfer.to_wallet.id),
            name=transfer.to_wallet.name,
            balance=str(transfer.to_wallet.balance),
        ),
        amount=str(transfer.amount),
        fee=str(transfer.fee),
        date=str(transfer.tx_date),
        note=transfer.note,
        created_at=transfer.created_at.isoformat(),
    )


async def list_transfers(
    db: AsyncSession,
    user_id: uuid.UUID,
    page: int = 1,
    size: int = 20,
) -> TransferListResponse:
    stmt = (
        select(Transfer)
        .options(
            selectinload(Transfer.from_wallet),
            selectinload(Transfer.to_wallet),
        )
        .where(Transfer.user_id == user_id)
        .order_by(Transfer.tx_date.desc(), Transfer.created_at.desc())
    )
    from sqlalchemy import func

    total = await db.scalar(
        select(func.count()).select_from(
            select(Transfer).where(Transfer.user_id == user_id).subquery()
        )
    ) or 0

    stmt = stmt.offset((page - 1) * size).limit(size)
    rows = await db.scalars(stmt)
    items = [_to_response(t) for t in rows.all()]

    return TransferListResponse(
        items=items,
        total=total,
        page=page,
        size=size,
        pages=math.ceil(total / size) if total else 0,
    )


async def get_transfer(
    db: AsyncSession, user_id: uuid.UUID, transfer_id: uuid.UUID
) -> TransferResponse:
    t = await db.scalar(
        select(Transfer)
        .options(selectinload(Transfer.from_wallet), selectinload(Transfer.to_wallet))
        .where(Transfer.id == transfer_id)
    )
    if not t:
        raise NotFoundException("Transfer")
    if t.user_id != user_id:
        raise ForbiddenException()
    return _to_response(t)


async def create_transfer(
    db: AsyncSession, user_id: uuid.UUID, data: TransferCreate
) -> TransferResponse:
    from_wallet = await db.get(Wallet, data.from_wallet_id)
    if not from_wallet or from_wallet.user_id != user_id or not from_wallet.is_active:
        raise NotFoundException("Source wallet")

    to_wallet = await db.get(Wallet, data.to_wallet_id)
    if not to_wallet or to_wallet.user_id != user_id or not to_wallet.is_active:
        raise NotFoundException("Destination wallet")

    total_debit = data.amount + data.fee
    if from_wallet.balance < total_debit:
        raise InsufficientBalanceException(from_wallet.name)

    # Build the transfer record
    transfer = Transfer(
        user_id=user_id,
        from_wallet_id=data.from_wallet_id,
        to_wallet_id=data.to_wallet_id,
        amount=data.amount,
        fee=data.fee,
        tx_date=data.date,
        note=data.note,
    )
    db.add(transfer)
    await db.flush()  # get transfer.id before creating transactions

    # Find or create system transfer categories
    expense_cat = await _get_or_create_transfer_category(db, user_id, "expense")
    income_cat = await _get_or_create_transfer_category(db, user_id, "income")

    # Expense transaction on source wallet
    db.add(
        Transaction(
            user_id=user_id,
            wallet_id=from_wallet.id,
            category_id=expense_cat.id,
            amount=total_debit,
            tx_type="expense",
            tx_date=data.date,
            note=f"Transfer to {to_wallet.name}" + (f", {data.note}" if data.note else ""),
            transfer_id=transfer.id,
        )
    )

    # Income transaction on destination wallet
    db.add(
        Transaction(
            user_id=user_id,
            wallet_id=to_wallet.id,
            category_id=income_cat.id,
            amount=data.amount,
            tx_type="income",
            tx_date=data.date,
            note=f"Transfer from {from_wallet.name}" + (f", {data.note}" if data.note else ""),
            transfer_id=transfer.id,
        )
    )

    # Update wallet balances
    from_wallet.balance -= total_debit
    to_wallet.balance += data.amount

    await db.commit()

    result = await db.scalar(
        select(Transfer)
        .options(selectinload(Transfer.from_wallet), selectinload(Transfer.to_wallet))
        .where(Transfer.id == transfer.id)
    )
    return _to_response(result)


async def cancel_transfer(
    db: AsyncSession, user_id: uuid.UUID, transfer_id: uuid.UUID
) -> None:
    transfer = await db.scalar(
        select(Transfer)
        .options(selectinload(Transfer.from_wallet), selectinload(Transfer.to_wallet))
        .where(Transfer.id == transfer_id)
    )
    if not transfer:
        raise NotFoundException("Transfer")
    if transfer.user_id != user_id:
        raise ForbiddenException()

    # Rollback wallet balances
    total_debit = transfer.amount + transfer.fee
    transfer.from_wallet.balance += total_debit
    transfer.to_wallet.balance -= transfer.amount

    # Delete generated transactions
    txs = await db.scalars(
        select(Transaction).where(Transaction.transfer_id == transfer.id)
    )
    for tx in txs.all():
        await db.delete(tx)

    await db.delete(transfer)
    await db.commit()


async def _get_or_create_transfer_category(
    db: AsyncSession, user_id: uuid.UUID, tx_type: str
) -> Category:
    """Get or create a hidden system category used for transfer transactions."""
    name = "Transfer In" if tx_type == "income" else "Transfer Out"
    cat = await db.scalar(
        select(Category).where(
            Category.user_id == user_id,
            Category.name == name,
            Category.is_default.is_(True),
        )
    )
    if cat:
        return cat
    cat = Category(
        user_id=user_id,
        name=name,
        type=tx_type,
        icon="swap_horiz",
        color="#9E9E9E",
        is_default=True,
    )
    db.add(cat)
    await db.flush()
    return cat
