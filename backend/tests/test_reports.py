from datetime import date
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_reports_and_export(client: AsyncClient):
    email = "reportuser@example.com"
    await client.post(
        "/api/v1/auth/register",
        json={"email": email, "full_name": "Report User", "password": "Password123"},
    )
    login_res = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "Password123"},
    )
    headers = {"Authorization": f"Bearer {login_res.json()['access_token']}"}

    today = date.today()
    start_date = today.replace(day=1)

    # 1. Summary
    sum_res = await client.get(
        "/api/v1/reports/summary",
        headers=headers,
        params={"year": today.year, "month": today.month},
    )
    assert sum_res.status_code == 200
    sum_data = sum_res.json()
    assert "income" in sum_data
    assert "expense" in sum_data
    assert "net" in sum_data

    # 2. Export CSV
    csv_res = await client.get(
        "/api/v1/reports/export/csv",
        headers=headers,
        params={"date_from": str(start_date), "date_to": str(today)},
    )
    assert csv_res.status_code == 200
    assert "text/csv" in csv_res.headers.get("content-type", "")
    assert len(csv_res.content) > 0

    # 3. Export Excel
    excel_res = await client.get(
        "/api/v1/reports/export/excel",
        headers=headers,
        params={"date_from": str(start_date), "date_to": str(today)},
    )
    assert excel_res.status_code == 200
    assert len(excel_res.content) > 0
