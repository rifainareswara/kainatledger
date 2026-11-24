from fastapi import APIRouter

from app.api.v1 import auth, categories, wallets, transactions, transfers, reports

api_router = APIRouter(prefix="/api/v1")

api_router.include_router(auth.router)
api_router.include_router(categories.router)
api_router.include_router(wallets.router)
api_router.include_router(transactions.router)
api_router.include_router(transfers.router)
api_router.include_router(reports.router)
