from decimal import Decimal
from typing import Optional
from pydantic import BaseModel, field_validator


WALLET_TYPES = ("cash", "bank", "e_wallet", "credit_card", "investment")


class WalletCreate(BaseModel):
    name: str
    type: str
    initial_balance: Decimal = Decimal("0.00")
    currency: str = "IDR"
    color: str = "#4A90E2"
    icon: str = "wallet"

    @field_validator("type")
    @classmethod
    def validate_type(cls, v: str) -> str:
        normalized = v.replace("-", "_")
        if normalized not in WALLET_TYPES:
            raise ValueError(f"type must be one of {WALLET_TYPES}")
        return normalized

    @field_validator("currency")
    @classmethod
    def validate_currency(cls, v: str) -> str:
        return v.upper()


class WalletUpdate(BaseModel):
    name: Optional[str] = None
    color: Optional[str] = None
    icon: Optional[str] = None


class WalletResponse(BaseModel):
    id: str
    name: str
    type: str
    balance: str
    currency: str
    color: str
    icon: str
    is_active: bool

    model_config = {"from_attributes": True}


class WalletSummaryResponse(BaseModel):
    total_balance: str
    currency: str
    wallet_count: int
    wallets: list[WalletResponse]
