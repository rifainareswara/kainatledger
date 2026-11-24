from typing import Optional
from pydantic import BaseModel, field_validator


class CategoryCreate(BaseModel):
    name: str
    type: str  # "income" | "expense"
    icon: str
    color: str

    @field_validator("type")
    @classmethod
    def validate_type(cls, v: str) -> str:
        if v not in ("income", "expense"):
            raise ValueError("type must be 'income' or 'expense'")
        return v

    @field_validator("color")
    @classmethod
    def validate_color(cls, v: str) -> str:
        if not v.startswith("#") or len(v) not in (4, 7):
            raise ValueError("color must be a hex value like #RGB or #RRGGBB")
        return v.upper()


class CategoryUpdate(BaseModel):
    name: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[str] = None

    @field_validator("color")
    @classmethod
    def validate_color(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            if not v.startswith("#") or len(v) not in (4, 7):
                raise ValueError("color must be a hex value like #RGB or #RRGGBB")
            return v.upper()
        return v


class CategoryResponse(BaseModel):
    id: str
    name: str
    type: str
    icon: str
    color: str
    is_default: bool
    transaction_count: int = 0

    model_config = {"from_attributes": True}
