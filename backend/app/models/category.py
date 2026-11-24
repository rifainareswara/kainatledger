import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING, List, Optional

import sqlalchemy as sa
from sqlmodel import Field, Relationship, SQLModel

if TYPE_CHECKING:
    from app.models.transaction import Transaction
    from app.models.user import User


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class Category(SQLModel, table=True):
    __tablename__ = "categories"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    name: str = Field(max_length=100)
    # Stored as plain string "income"/"expense" — no PG enum type needed
    type: str = Field(
        sa_column=sa.Column("type", sa.String(10), nullable=False),
    )
    icon: str = Field(max_length=50)
    color: str = Field(max_length=7)
    is_default: bool = Field(default=False)
    created_at: datetime = Field(default_factory=utcnow)

    # Relationships
    owner: Optional["User"] = Relationship(back_populates="categories")
    transactions: List["Transaction"] = Relationship(back_populates="category")
