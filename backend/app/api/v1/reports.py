import calendar
from datetime import date, datetime

from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.report import (
    CashFlowResponse,
    CategoryReportResponse,
    MonthlyReportResponse,
    SummaryResponse,
)
from app.services import report_service

router = APIRouter(prefix="/reports", tags=["reports"])


@router.get("/summary", response_model=SummaryResponse)
async def summary(
    year: int = Query(default_factory=lambda: datetime.now().year),
    month: int = Query(default_factory=lambda: datetime.now().month, ge=1, le=12),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await report_service.get_summary(db, current_user.id, year, month)


@router.get("/monthly", response_model=MonthlyReportResponse)
async def monthly(
    year: int = Query(default_factory=lambda: datetime.now().year),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await report_service.get_monthly_report(db, current_user.id, year)


@router.get("/by-category", response_model=CategoryReportResponse)
async def by_category(
    type: str = Query("expense", pattern="^(income|expense)$"),
    date_from: date = Query(...),
    date_to: date = Query(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await report_service.get_category_report(
        db, current_user.id, type, date_from, date_to
    )


@router.get("/cash-flow", response_model=CashFlowResponse)
async def cash_flow(
    date_from: date = Query(...),
    date_to: date = Query(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await report_service.get_cash_flow(db, current_user.id, date_from, date_to)


@router.get("/export/csv")
async def export_csv(
    date_from: date = Query(...),
    date_to: date = Query(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    content = await report_service.export_transactions_csv(
        db, current_user.id, date_from, date_to
    )
    filename = f"kainatledger-{date_from}-to-{date_to}.csv"
    return Response(
        content=content,
        media_type="text/csv",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@router.get("/export/excel")
async def export_excel(
    date_from: date = Query(...),
    date_to: date = Query(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    content = await report_service.export_transactions_excel(
        db, current_user.id, date_from, date_to
    )
    filename = f"kainatledger-{date_from}-to-{date_to}.xlsx"
    return Response(
        content=content,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
