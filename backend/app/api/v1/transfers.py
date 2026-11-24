import uuid

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.transfer import TransferCreate, TransferListResponse, TransferResponse
from app.services import transfer_service

router = APIRouter(prefix="/transfers", tags=["transfers"])


@router.get("", response_model=TransferListResponse)
async def list_transfers(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await transfer_service.list_transfers(db, current_user.id, page, size)


@router.post("", response_model=TransferResponse, status_code=status.HTTP_201_CREATED)
async def create_transfer(
    data: TransferCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await transfer_service.create_transfer(db, current_user.id, data)


@router.get("/{transfer_id}", response_model=TransferResponse)
async def get_transfer(
    transfer_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await transfer_service.get_transfer(db, current_user.id, transfer_id)


@router.delete("/{transfer_id}", status_code=status.HTTP_204_NO_CONTENT)
async def cancel_transfer(
    transfer_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await transfer_service.cancel_transfer(db, current_user.id, transfer_id)
