import uuid
from datetime import date
from decimal import Decimal
from typing import Optional
from pydantic import BaseModel, field_validator, model_validator


class WalletBrief(BaseModel):
    id: str
    name: str
    balance: str
    model_config = {"from_attributes": True}


class TransferCreate(BaseModel):
    from_wallet_id: uuid.UUID
    to_wallet_id: uuid.UUID
    amount: Decimal
    fee: Decimal = Decimal("0.00")
    date: date
    note: Optional[str] = None

    @field_validator("amount")
    @classmethod
    def amount_positive(cls, v: Decimal) -> Decimal:
        if v <= 0:
            raise ValueError("amount must be greater than zero")
        return v

    @field_validator("fee")
    @classmethod
    def fee_non_negative(cls, v: Decimal) -> Decimal:
        if v < 0:
            raise ValueError("fee cannot be negative")
        return v

    @model_validator(mode="after")
    def wallets_differ(self) -> "TransferCreate":
        if self.from_wallet_id == self.to_wallet_id:
            raise ValueError("from_wallet_id and to_wallet_id must be different")
        return self


class TransferResponse(BaseModel):
    id: str
    from_wallet: WalletBrief
    to_wallet: WalletBrief
    amount: str
    fee: str
    date: str
    note: Optional[str]
    created_at: str
    model_config = {"from_attributes": True}


class TransferListResponse(BaseModel):
    items: list[TransferResponse]
    total: int
    page: int
    size: int
    pages: int
