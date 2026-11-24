from datetime import date
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_atomic_transfers(client: AsyncClient):
    email = "transferuser@example.com"
    await client.post(
        "/api/v1/auth/register",
        json={"email": email, "full_name": "Transfer User", "password": "Password123"},
    )
    login_res = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "Password123"},
    )
    headers = {"Authorization": f"Bearer {login_res.json()['access_token']}"}

    # Wallet A (100,000)
    w_a = await client.post(
        "/api/v1/wallets",
        headers=headers,
        json={"name": "Wallet A", "type": "bank", "initial_balance": 100000.0},
    )
    w_a_id = w_a.json()["id"]

    # Wallet B (50,000)
    w_b = await client.post(
        "/api/v1/wallets",
        headers=headers,
        json={"name": "Wallet B", "type": "e-wallet", "initial_balance": 50000.0},
    )
    w_b_id = w_b.json()["id"]

    # Transfer 30,000 from A to B with fee 2,500
    transfer_res = await client.post(
        "/api/v1/transfers",
        headers=headers,
        json={
            "from_wallet_id": w_a_id,
            "to_wallet_id": w_b_id,
            "amount": 30000.0,
            "fee": 2500.0,
            "date": str(date.today()),
            "note": "Top up e-wallet",
        },
    )
    assert transfer_res.status_code == 201

    # Check updated balances
    res_a = await client.get(f"/api/v1/wallets/{w_a_id}", headers=headers)
    res_b = await client.get(f"/api/v1/wallets/{w_b_id}", headers=headers)

    # Wallet A: 100,000 - 30,000 - 2,500 = 67,500
    assert float(res_a.json()["balance"]) == 67500.0
    # Wallet B: 50,000 + 30,000 = 80,000
    assert float(res_b.json()["balance"]) == 80000.0
