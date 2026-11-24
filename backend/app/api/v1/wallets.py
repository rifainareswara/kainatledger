import uuid

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.wallet import (
    WalletCreate,
    WalletResponse,
    WalletSummaryResponse,
    WalletUpdate,
)
from app.services import wallet_service

router = APIRouter(prefix="/wallets", tags=["wallets"])


@router.get("/summary", response_model=WalletSummaryResponse)
async def wallet_summary(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await wallet_service.get_wallet_summary(db, current_user.id)


@router.get("", response_model=list[WalletResponse])
async def list_wallets(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await wallet_service.list_wallets(db, current_user.id)


@router.post("", response_model=WalletResponse, status_code=status.HTTP_201_CREATED)
async def create_wallet(
    data: WalletCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await wallet_service.create_wallet(db, current_user.id, data)


@router.get("/{wallet_id}", response_model=WalletResponse)
async def get_wallet(
    wallet_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await wallet_service.get_wallet(db, current_user.id, wallet_id)


@router.put("/{wallet_id}", response_model=WalletResponse)
async def update_wallet(
    wallet_id: uuid.UUID,
    data: WalletUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await wallet_service.update_wallet(db, current_user.id, wallet_id, data)


@router.delete("/{wallet_id}", status_code=status.HTTP_204_NO_CONTENT)
async def deactivate_wallet(
    wallet_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await wallet_service.deactivate_wallet(db, current_user.id, wallet_id)
