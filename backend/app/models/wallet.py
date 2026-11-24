import uuid
from datetime import datetime, timezone
from decimal import Decimal
from typing import TYPE_CHECKING, List, Optional

import sqlalchemy as sa
from sqlmodel import Field, Relationship, SQLModel

if TYPE_CHECKING:
    from app.models.transaction import Transaction
    from app.models.transfer import Transfer
    from app.models.user import User


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class Wallet(SQLModel, table=True):
    __tablename__ = "wallets"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    name: str = Field(max_length=100)
    # Stored as plain string — no PG enum type
    type: str = Field(
        sa_column=sa.Column("type", sa.String(20), nullable=False),
    )
    balance: Decimal = Field(default=Decimal("0.00"), decimal_places=2, max_digits=15)
    currency: str = Field(default="IDR", max_length=3)
    color: str = Field(default="#4A90E2", max_length=7)
    icon: str = Field(default="wallet", max_length=50)
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=utcnow)
    updated_at: datetime = Field(default_factory=utcnow)

    # Relationships
    owner: Optional["User"] = Relationship(back_populates="wallets")
    transactions: List["Transaction"] = Relationship(back_populates="wallet")
    transfers_from: List["Transfer"] = Relationship(
        back_populates="from_wallet",
        sa_relationship_kwargs={"foreign_keys": "Transfer.from_wallet_id"},
    )
    transfers_to: List["Transfer"] = Relationship(
        back_populates="to_wallet",
        sa_relationship_kwargs={"foreign_keys": "Transfer.to_wallet_id"},
    )
