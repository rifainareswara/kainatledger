import calendar
import io
import uuid
from datetime import date
from decimal import Decimal
from typing import Optional

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.category import Category
from app.models.transaction import Transaction
from app.models.wallet import Wallet
from app.schemas.report import (
    CashFlowDataPoint,
    CashFlowResponse,
    CategoryBreakdownItem,
    CategoryReportResponse,
    MonthlyDataPoint,
    MonthlyReportResponse,
    SummaryResponse,
    WalletBrief,
)

MONTH_NAMES = [
    "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
]


async def get_summary(
    db: AsyncSession, user_id: uuid.UUID, year: int, month: int
) -> SummaryResponse:
    # Wallet balances
    wallets = await db.scalars(
        select(Wallet).where(Wallet.user_id == user_id, Wallet.is_active.is_(True))
    )
    wallet_list = wallets.all()
    total_balance = sum(w.balance for w in wallet_list)

    # Period income / expense (exclude transfer transactions)
    start = date(year, month, 1)
    end = date(year, month, calendar.monthrange(year, month)[1])

    rows = await db.execute(
        select(Transaction.tx_type, func.sum(Transaction.amount).label("total"))
        .where(
            Transaction.user_id == user_id,
            Transaction.tx_date >= start,
            Transaction.tx_date <= end,
            Transaction.transfer_id.is_(None),
        )
        .group_by(Transaction.tx_type)
    )
    agg = {row.tx_type: row.total for row in rows}
    income = agg.get("income", Decimal("0"))
    expense = agg.get("expense", Decimal("0"))

    return SummaryResponse(
        period={"year": year, "month": month},
        total_balance=str(total_balance),
        income=str(income),
        expense=str(expense),
        net=str(income - expense),
        wallets=[
            WalletBrief(id=str(w.id), name=w.name, balance=str(w.balance))
            for w in wallet_list
        ],
    )


async def get_monthly_report(
    db: AsyncSession, user_id: uuid.UUID, year: int
) -> MonthlyReportResponse:
    rows = await db.execute(
        select(
            func.extract("month", Transaction.tx_date).label("month"),
            Transaction.tx_type,
            func.sum(Transaction.amount).label("total"),
        )
        .where(
            Transaction.user_id == user_id,
            func.extract("year", Transaction.tx_date) == year,
            Transaction.transfer_id.is_(None),
        )
        .group_by("month", Transaction.tx_type)
        .order_by("month")
    )

    agg: dict[int, dict[str, Decimal]] = {}
    for row in rows:
        m = int(row.month)
        agg.setdefault(m, {})
        agg[m][row.tx_type] = row.total

    data = [
        MonthlyDataPoint(
            month=m,
            month_name=MONTH_NAMES[m],
            income=str(agg.get(m, {}).get("income", Decimal("0"))),
            expense=str(agg.get(m, {}).get("expense", Decimal("0"))),
        )
        for m in range(1, 13)
    ]
    return MonthlyReportResponse(year=year, data=data)


async def get_category_report(
    db: AsyncSession,
    user_id: uuid.UUID,
    tx_type: str,
    date_from: date,
    date_to: date,
) -> CategoryReportResponse:
    rows = await db.execute(
        select(
            Transaction.category_id,
            func.sum(Transaction.amount).label("total"),
            func.count(Transaction.id).label("cnt"),
        )
        .where(
            Transaction.user_id == user_id,
            Transaction.tx_type == tx_type,
            Transaction.tx_date >= date_from,
            Transaction.tx_date <= date_to,
            Transaction.transfer_id.is_(None),
        )
        .group_by(Transaction.category_id)
        .order_by(func.sum(Transaction.amount).desc())
    )
    aggregated = rows.all()

    grand_total = sum(r.total for r in aggregated) or Decimal("0")
    items = []
    for row in aggregated:
        cat = await db.get(Category, row.category_id)
        if not cat:
            continue
        pct = float(row.total / grand_total * 100) if grand_total else 0.0
        items.append(
            CategoryBreakdownItem(
                category_id=str(cat.id),
                category_name=cat.name,
                icon=cat.icon,
                color=cat.color,
                amount=str(row.total),
                percentage=round(pct, 1),
                transaction_count=row.cnt,
            )
        )

    return CategoryReportResponse(
        type=tx_type,
        total=str(grand_total),
        items=items,
    )


async def get_cash_flow(
    db: AsyncSession,
    user_id: uuid.UUID,
    date_from: date,
    date_to: date,
) -> CashFlowResponse:
    rows = await db.execute(
        select(
            Transaction.tx_date,
            Transaction.tx_type,
            func.sum(Transaction.amount).label("total"),
        )
        .where(
            Transaction.user_id == user_id,
            Transaction.tx_date >= date_from,
            Transaction.tx_date <= date_to,
            Transaction.transfer_id.is_(None),
        )
        .group_by(Transaction.tx_date, Transaction.tx_type)
        .order_by(Transaction.tx_date)
    )

    agg: dict[date, dict[str, Decimal]] = {}
    for row in rows:
        agg.setdefault(row.tx_date, {})
        agg[row.tx_date][row.tx_type] = row.total

    # Fill every day in range (even days with no transactions)
    from datetime import timedelta

    data = []
    current = date_from
    while current <= date_to:
        inc = agg.get(current, {}).get("income", Decimal("0"))
        exp = agg.get(current, {}).get("expense", Decimal("0"))
        data.append(
            CashFlowDataPoint(
                date=str(current),
                income=str(inc),
                expense=str(exp),
                net=str(inc - exp),
            )
        )
        current += timedelta(days=1)

    return CashFlowResponse(
        date_from=str(date_from),
        date_to=str(date_to),
        data=data,
    )


async def export_transactions_csv(
    db: AsyncSession,
    user_id: uuid.UUID,
    date_from: date,
    date_to: date,
) -> bytes:
    import csv

    rows = await db.scalars(
        select(Transaction)
        .options(selectinload(Transaction.category), selectinload(Transaction.wallet))
        .where(
            Transaction.user_id == user_id,
            Transaction.tx_date >= date_from,
            Transaction.tx_date <= date_to,
            Transaction.transfer_id.is_(None),
        )
        .order_by(Transaction.tx_date.desc())
    )
    transactions = rows.all()

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["Tanggal", "Jenis", "Kategori", "Dompet", "Nominal", "Metode", "Catatan"])
    for tx in transactions:
        writer.writerow([
            str(tx.tx_date),
            "Pemasukan" if tx.tx_type == "income" else "Pengeluaran",
            tx.category.name if tx.category else "",
            tx.wallet.name if tx.wallet else "",
            str(tx.amount),
            tx.payment_method or "",
            tx.note or "",
        ])
    return output.getvalue().encode("utf-8-sig")  # BOM for Excel compatibility


async def export_transactions_excel(
    db: AsyncSession,
    user_id: uuid.UUID,
    date_from: date,
    date_to: date,
) -> bytes:
    import openpyxl
    from openpyxl.styles import Font, PatternFill, Alignment

    rows = await db.scalars(
        select(Transaction)
        .options(selectinload(Transaction.category), selectinload(Transaction.wallet))
        .where(
            Transaction.user_id == user_id,
            Transaction.tx_date >= date_from,
            Transaction.tx_date <= date_to,
            Transaction.transfer_id.is_(None),
        )
        .order_by(Transaction.tx_date.desc())
    )
    transactions = rows.all()

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Transactions"

    headers = ["Tanggal", "Jenis", "Kategori", "Dompet", "Nominal", "Metode", "Catatan"]
    header_fill = PatternFill(start_color="2563EB", end_color="2563EB", fill_type="solid")
    header_font = Font(bold=True, color="FFFFFF")

    for col, header in enumerate(headers, 1):
        cell = ws.cell(row=1, column=col, value=header)
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(horizontal="center")

    for row_idx, tx in enumerate(transactions, 2):
        ws.cell(row=row_idx, column=1, value=str(tx.tx_date))
        ws.cell(row=row_idx, column=2, value="Pemasukan" if tx.tx_type == "income" else "Pengeluaran")
        ws.cell(row=row_idx, column=3, value=tx.category.name if tx.category else "")
        ws.cell(row=row_idx, column=4, value=tx.wallet.name if tx.wallet else "")
        ws.cell(row=row_idx, column=5, value=float(tx.amount))
        ws.cell(row=row_idx, column=6, value=tx.payment_method or "")
        ws.cell(row=row_idx, column=7, value=tx.note or "")

    # Auto-fit column widths (approximation)
    for col in ws.columns:
        max_len = max((len(str(cell.value)) if cell.value else 0) for cell in col)
        ws.column_dimensions[col[0].column_letter].width = min(max_len + 4, 40)

    buf = io.BytesIO()
    wb.save(buf)
    return buf.getvalue()
