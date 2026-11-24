from datetime import date
import pytest
from httpx import AsyncClient

async def setup_user_and_wallet(client: AsyncClient):
    email = "txuser@example.com"
    await client.post(
        "/api/v1/auth/register",
        json={"email": email, "full_name": "Tx User", "password": "Password123"},
    )
    login_res = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "Password123"},
    )
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Wallet with 500,000 balance
    w_res = await client.post(
        "/api/v1/wallets",
        headers=headers,
        json={
            "name": "Kas Harian",
            "type": "cash",
            "initial_balance": 500000.0,
            "currency": "IDR",
            "color": "#16A34A",
            "icon": "money",
        },
    )
    wallet_id = w_res.json()["id"]

    # Default category exists or create one
    c_res = await client.post(
        "/api/v1/categories",
        headers=headers,
        json={
            "name": "Makan Siang",
            "type": "expense",
            "icon": "restaurant",
            "color": "#DC2626",
        },
    )
    cat_id = c_res.json()["id"]

    return headers, wallet_id, cat_id

@pytest.mark.asyncio
async def test_transactions_and_balance_correction(client: AsyncClient):
    headers, wallet_id, cat_id = await setup_user_and_wallet(client)

    # 1. Create expense transaction: 50,000
    tx_res = await client.post(
        "/api/v1/transactions",
        headers=headers,
        json={
            "wallet_id": wallet_id,
            "category_id": cat_id,
            "amount": 50000.0,
            "date": str(date.today()),
            "note": "Makan di warung",
        },
    )
    assert tx_res.status_code == 201
    tx = tx_res.json()
    assert float(tx["amount"]) == 50000.0
    tx_id = tx["id"]

    # Wallet balance should now be 500,000 - 50,000 = 450,000
    w_res = await client.get(f"/api/v1/wallets/{wallet_id}", headers=headers)
    assert float(w_res.json()["balance"]) == 450000.0

    # 2. Delete transaction -> balance should be reverted back to 500,000
    del_res = await client.delete(f"/api/v1/transactions/{tx_id}", headers=headers)
    assert del_res.status_code == 204

    w_res2 = await client.get(f"/api/v1/wallets/{wallet_id}", headers=headers)
    assert float(w_res2.json()["balance"]) == 500000.0
