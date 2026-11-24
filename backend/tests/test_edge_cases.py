import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_unauthenticated_requests_fail(client: AsyncClient):
    endpoints = [
        "/api/v1/wallets",
        "/api/v1/wallets/summary",
        "/api/v1/categories",
        "/api/v1/transactions",
        "/api/v1/transfers",
        "/api/v1/reports/summary",
    ]
    for ep in endpoints:
        res = await client.get(ep)
        assert res.status_code == 401, f"{ep} should require authentication"

@pytest.mark.asyncio
async def test_invalid_jwt_token_fails(client: AsyncClient):
    res = await client.get(
        "/api/v1/wallets",
        headers={"Authorization": "Bearer invalid.jwt.token"},
    )
    assert res.status_code == 401

@pytest.mark.asyncio
async def test_transfer_edge_cases(client: AsyncClient):
    email = "edgecaseuser@example.com"
    await client.post(
        "/api/v1/auth/register",
        json={"email": email, "full_name": "Edge User", "password": "Password123"},
    )
    login_res = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "Password123"},
    )
    headers = {"Authorization": f"Bearer {login_res.json()['access_token']}"}

    # Create wallet with 50,000
    w_res = await client.post(
        "/api/v1/wallets",
        headers=headers,
        json={"name": "Wallet Edge", "type": "cash", "initial_balance": 50000.0},
    )
    w_id = w_res.json()["id"]

    # 1. Transfer to same wallet should fail with 422
    same_res = await client.post(
        "/api/v1/transfers",
        headers=headers,
        json={
            "from_wallet_id": w_id,
            "to_wallet_id": w_id,
            "amount": 10000.0,
            "date": "2026-11-23",
        },
    )
    assert same_res.status_code == 422

    # 2. Transfer with negative amount should fail with 422
    neg_res = await client.post(
        "/api/v1/transfers",
        headers=headers,
        json={
            "from_wallet_id": w_id,
            "to_wallet_id": w_id,
            "amount": -10000.0,
            "date": "2026-11-23",
        },
    )
    assert neg_res.status_code == 422
