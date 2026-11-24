import pytest
from httpx import AsyncClient

async def get_auth_token(client: AsyncClient, email="walletuser@example.com") -> str:
    await client.post(
        "/api/v1/auth/register",
        json={"email": email, "full_name": "Wallet User", "password": "Password123"},
    )
    res = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "Password123"},
    )
    return res.json()["access_token"]

@pytest.mark.asyncio
async def test_wallets_crud(client: AsyncClient):
    token = await get_auth_token(client)
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Create wallet
    create_res = await client.post(
        "/api/v1/wallets",
        headers=headers,
        json={
            "name": "BCA Utama",
            "type": "bank",
            "initial_balance": 1500000.0,
            "currency": "IDR",
            "color": "#2563EB",
            "icon": "account_balance",
        },
    )
    assert create_res.status_code == 201
    wallet = create_res.json()
    assert wallet["name"] == "BCA Utama"
    assert float(wallet["balance"]) == 1500000.0
    wallet_id = wallet["id"]

    # 2. Get list of wallets
    list_res = await client.get("/api/v1/wallets", headers=headers)
    assert list_res.status_code == 200
    wallets = list_res.json()
    assert len(wallets) >= 1
    assert any(w["id"] == wallet_id for w in wallets)

    # 3. Get summary
    summary_res = await client.get("/api/v1/wallets/summary", headers=headers)
    assert summary_res.status_code == 200
    assert float(summary_res.json()["total_balance"]) >= 1500000.0

    # 4. Deactivate wallet
    del_res = await client.delete(f"/api/v1/wallets/{wallet_id}", headers=headers)
    assert del_res.status_code == 204
