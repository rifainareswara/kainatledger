import math
import uuid
from datetime import date
from decimal import Decimal
from typing import Optional

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import ForbiddenException, InsufficientBalanceException, NotFoundException
from app.models.category import Category
from app.models.transaction import Transaction
from app.models.wallet import Wallet
from app.schemas.transaction import (
    CategoryBrief,
    TransactionCreate,
    TransactionListResponse,
    TransactionResponse,
    TransactionUpdate,
    WalletBrief,
)


def _to_response(tx: Transaction) -> TransactionResponse:
    return TransactionResponse(
        id=str(tx.id),
        amount=str(tx.amount),
        type=tx.tx_type,
        date=str(tx.tx_date),
        note=tx.note,
        payment_method=tx.payment_method,
        category=CategoryBrief(
            id=str(tx.category.id),
            name=tx.category.name,
            icon=tx.category.icon,
            color=tx.category.color,
        ),
        wallet=WalletBrief(
            id=str(tx.wallet.id),
            name=tx.wallet.name,
            type=tx.wallet.type,
        ),
        created_at=tx.created_at.isoformat(),
    )


async def list_transactions(
    db: AsyncSession,
    user_id: uuid.UUID,
    page: int = 1,
    size: int = 20,
    type_filter: Optional[str] = None,
    wallet_id: Optional[uuid.UUID] = None,
    category_id: Optional[uuid.UUID] = None,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
    search: Optional[str] = None,
    sort_by: str = "date",
    sort_order: str = "desc",
) -> TransactionListResponse:
    from sqlalchemy.orm import selectinload

    stmt = (
        select(Transaction)
        .options(selectinload(Transaction.category), selectinload(Transaction.wallet))
        .where(Transaction.user_id == user_id)
    )

    if type_filter:
        stmt = stmt.where(Transaction.tx_type == type_filter)
    if wallet_id:
        stmt = stmt.where(Transaction.wallet_id == wallet_id)
    if category_id:
        stmt = stmt.where(Transaction.category_id == category_id)
    if date_from:
        stmt = stmt.where(Transaction.tx_date >= date_from)
    if date_to:
        stmt = stmt.where(Transaction.tx_date <= date_to)
    if search:
        stmt = stmt.where(Transaction.note.ilike(f"%{search}%"))

    # Exclude transfer-generated transactions from default list
    stmt = stmt.where(Transaction.transfer_id.is_(None))

    total_stmt = select(func.count()).select_from(stmt.subquery())
    total = await db.scalar(total_stmt) or 0

    sort_col = Transaction.tx_date if sort_by == "date" else Transaction.amount
    stmt = stmt.order_by(
        sort_col.desc() if sort_order == "desc" else sort_col.asc()
    )
    stmt = stmt.offset((page - 1) * size).limit(size)

    rows = await db.scalars(stmt)
    items = [_to_response(tx) for tx in rows.all()]

    return TransactionListResponse(
        items=items,
        total=total,
        page=page,
        size=size,
        pages=math.ceil(total / size) if total else 0,
    )


async def get_transaction(
    db: AsyncSession, user_id: uuid.UUID, tx_id: uuid.UUID
) -> TransactionResponse:
    from sqlalchemy.orm import selectinload

    tx = await db.scalar(
        select(Transaction)
        .options(selectinload(Transaction.category), selectinload(Transaction.wallet))
        .where(Transaction.id == tx_id)
    )
    if not tx:
        raise NotFoundException("Transaction")
    if tx.user_id != user_id:
        raise ForbiddenException()
    return _to_response(tx)


async def create_transaction(
    db: AsyncSession, user_id: uuid.UUID, data: TransactionCreate
) -> TransactionResponse:
    from sqlalchemy.orm import selectinload

    # Validate wallet ownership
    wallet = await db.get(Wallet, data.wallet_id)
    if not wallet or wallet.user_id != user_id:
        raise NotFoundException("Wallet")

    # Validate category ownership
    category = await db.get(Category, data.category_id)
    if not category or category.user_id != user_id:
        raise NotFoundException("Category")

    tx_type = category.type

    if tx_type == "expense" and wallet.balance < data.amount:
        raise InsufficientBalanceException(wallet.name)

    # Update wallet balance
    if tx_type == "income":
        wallet.balance += data.amount
    else:
        wallet.balance -= data.amount

    tx = Transaction(
        user_id=user_id,
        wallet_id=data.wallet_id,
        category_id=data.category_id,
        amount=data.amount,
        tx_type=tx_type,
        tx_date=data.date,
        note=data.note,
        payment_method=data.payment_method,
    )
    db.add(tx)
    await db.commit()

    # Reload with relationships
    result = await db.scalar(
        select(Transaction)
        .options(selectinload(Transaction.category), selectinload(Transaction.wallet))
        .where(Transaction.id == tx.id)
    )
    return _to_response(result)


async def update_transaction(
    db: AsyncSession,
    user_id: uuid.UUID,
    tx_id: uuid.UUID,
    data: TransactionUpdate,
) -> TransactionResponse:
    from sqlalchemy.orm import selectinload

    tx = await db.get(Transaction, tx_id)
    if not tx:
        raise NotFoundException("Transaction")
    if tx.user_id != user_id:
        raise ForbiddenException()
    if tx.transfer_id:
        raise ForbiddenException("Transfer transactions cannot be edited directly")

    # Reverse old effect on wallet
    old_wallet = await db.get(Wallet, tx.wallet_id)
    if tx.tx_type == "income":
        old_wallet.balance -= tx.amount
    else:
        old_wallet.balance += tx.amount

    # Determine new values
    new_wallet_id = data.wallet_id or tx.wallet_id
    new_category_id = data.category_id or tx.category_id
    new_amount = data.amount or tx.amount
    new_date = data.date or tx.tx_date

    new_wallet = await db.get(Wallet, new_wallet_id)
    if not new_wallet or new_wallet.user_id != user_id:
        raise NotFoundException("Wallet")

    new_category = await db.get(Category, new_category_id)
    if not new_category or new_category.user_id != user_id:
        raise NotFoundException("Category")

    new_type = new_category.type

    if new_type == "expense" and new_wallet.balance < new_amount:
        raise InsufficientBalanceException(new_wallet.name)

    # Apply new effect
    if new_type == "income":
        new_wallet.balance += new_amount
    else:
        new_wallet.balance -= new_amount

    tx.wallet_id = new_wallet_id
    tx.category_id = new_category_id
    tx.amount = new_amount
    tx.tx_type = new_type
    tx.tx_date = new_date
    if data.note is not None:
        tx.note = data.note
    if data.payment_method is not None:
        tx.payment_method = data.payment_method

    await db.commit()

    result = await db.scalar(
        select(Transaction)
        .options(selectinload(Transaction.category), selectinload(Transaction.wallet))
        .where(Transaction.id == tx.id)
    )
    return _to_response(result)


async def delete_transaction(
    db: AsyncSession, user_id: uuid.UUID, tx_id: uuid.UUID
) -> None:
    tx = await db.get(Transaction, tx_id)
    if not tx:
        raise NotFoundException("Transaction")
    if tx.user_id != user_id:
        raise ForbiddenException()
    if tx.transfer_id:
        raise ForbiddenException("Transfer transactions cannot be deleted directly")

    # Reverse wallet balance
    wallet = await db.get(Wallet, tx.wallet_id)
    if wallet:
        if tx.tx_type == "income":
            wallet.balance -= tx.amount
        else:
            wallet.balance += tx.amount

    await db.delete(tx)
    await db.commit()
