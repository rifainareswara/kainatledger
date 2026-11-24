from pydantic import BaseModel


class WalletBrief(BaseModel):
    id: str
    name: str
    balance: str


class SummaryResponse(BaseModel):
    period: dict
    total_balance: str
    income: str
    expense: str
    net: str
    wallets: list[WalletBrief]


class MonthlyDataPoint(BaseModel):
    month: int
    month_name: str
    income: str
    expense: str


class MonthlyReportResponse(BaseModel):
    year: int
    data: list[MonthlyDataPoint]


class CategoryBreakdownItem(BaseModel):
    category_id: str
    category_name: str
    icon: str
    color: str
    amount: str
    percentage: float
    transaction_count: int


class CategoryReportResponse(BaseModel):
    type: str
    total: str
    items: list[CategoryBreakdownItem]


class CashFlowDataPoint(BaseModel):
    date: str
    income: str
    expense: str
    net: str


class CashFlowResponse(BaseModel):
    date_from: str
    date_to: str
    data: list[CashFlowDataPoint]
