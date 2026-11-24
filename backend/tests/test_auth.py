import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_register_and_login_success(client: AsyncClient):
    # 1. Register
    reg_res = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "user@example.com",
            "full_name": "Test User",
            "password": "Password123",
        },
    )
    assert reg_res.status_code == 201
    reg_data = reg_res.json()
    assert reg_data["email"] == "user@example.com"
    assert reg_data["full_name"] == "Test User"
    assert "id" in reg_data

    # Verify X-Request-ID header exists
    assert "x-request-id" in reg_res.headers

    # 2. Duplicate register fails
    dup_res = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "user@example.com",
            "full_name": "Test User 2",
            "password": "Password123",
        },
    )
    assert dup_res.status_code == 409

    # 3. Login
    login_res = await client.post(
        "/api/v1/auth/login",
        json={
            "email": "user@example.com",
            "password": "Password123",
        },
    )
    assert login_res.status_code == 200
    login_data = login_res.json()
    assert "access_token" in login_data
    assert "refresh_token" in login_data
    assert login_data["token_type"] == "bearer"

    # 4. Wrong password fails
    wrong_res = await client.post(
        "/api/v1/auth/login",
        json={
            "email": "user@example.com",
            "password": "WrongPassword123",
        },
    )
    assert wrong_res.status_code == 401

    # 5. Refresh token
    refresh_res = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": login_data["refresh_token"]},
    )
    assert refresh_res.status_code == 200
    assert "access_token" in refresh_res.json()

    # 6. Logout
    logout_res = await client.post(
        "/api/v1/auth/logout",
        headers={"Authorization": f"Bearer {login_data['access_token']}"},
        json={"refresh_token": login_data["refresh_token"]},
    )
    assert logout_res.status_code == 204
