import uuid
from datetime import date
from decimal import Decimal
from typing import Optional
from pydantic import BaseModel, field_validator

PAYMENT_METHODS = ("cash", "transfer", "debit_card", "credit_card", "qr_code", "auto_debit")


class CategoryBrief(BaseModel):
    id: str
    name: str
    icon: str
    color: str
    model_config = {"from_attributes": True}


class WalletBrief(BaseModel):
    id: str
    name: str
    type: str
    model_config = {"from_attributes": True}


class TransactionCreate(BaseModel):
    wallet_id: uuid.UUID
    category_id: uuid.UUID
    amount: Decimal
    date: date
    note: Optional[str] = None
    payment_method: Optional[str] = None

    @field_validator("amount")
    @classmethod
    def amount_positive(cls, v: Decimal) -> Decimal:
        if v <= 0:
            raise ValueError("amount must be greater than zero")
        return v

    @field_validator("payment_method")
    @classmethod
    def validate_payment_method(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and v not in PAYMENT_METHODS:
            raise ValueError(f"payment_method must be one of {PAYMENT_METHODS}")
        return v


class TransactionUpdate(BaseModel):
    wallet_id: Optional[uuid.UUID] = None
    category_id: Optional[uuid.UUID] = None
    amount: Optional[Decimal] = None
    date: Optional[date] = None
    note: Optional[str] = None
    payment_method: Optional[str] = None

    @field_validator("amount")
    @classmethod
    def amount_positive(cls, v: Optional[Decimal]) -> Optional[Decimal]:
        if v is not None and v <= 0:
            raise ValueError("amount must be greater than zero")
        return v


class TransactionResponse(BaseModel):
    id: str
    amount: str
    type: str
    date: str
    note: Optional[str]
    payment_method: Optional[str]
    category: CategoryBrief
    wallet: WalletBrief
    created_at: str
    model_config = {"from_attributes": True}


class TransactionListResponse(BaseModel):
    items: list[TransactionResponse]
    total: int
    page: int
    size: int
    pages: int
