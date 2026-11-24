import uuid
from datetime import date as date_type, datetime, timezone
from decimal import Decimal
from typing import TYPE_CHECKING, List, Optional

import sqlalchemy as sa
from sqlmodel import Field, Relationship, SQLModel

if TYPE_CHECKING:
    from app.models.transaction import Transaction
    from app.models.wallet import Wallet


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class Transfer(SQLModel, table=True):
    __tablename__ = "transfers"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    from_wallet_id: uuid.UUID = Field(foreign_key="wallets.id", index=True)
    to_wallet_id: uuid.UUID = Field(foreign_key="wallets.id", index=True)

    amount: Decimal = Field(decimal_places=2, max_digits=15)
    fee: Decimal = Field(default=Decimal("0.00"), decimal_places=2, max_digits=15)
    tx_date: date_type = Field(
        sa_column=sa.Column("date", sa.Date(), index=True, nullable=False),
    )
    note: Optional[str] = Field(default=None, max_length=500)

    created_at: datetime = Field(default_factory=utcnow)

    # Relationships
    from_wallet: Optional["Wallet"] = Relationship(
        back_populates="transfers_from",
        sa_relationship_kwargs={"foreign_keys": "Transfer.from_wallet_id"},
    )
    to_wallet: Optional["Wallet"] = Relationship(
        back_populates="transfers_to",
        sa_relationship_kwargs={"foreign_keys": "Transfer.to_wallet_id"},
    )
    # Two auto-generated transactions (expense + income)
    transactions: List["Transaction"] = Relationship(back_populates="transfer")
