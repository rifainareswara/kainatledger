FROM python:3.12-slim

WORKDIR /app

# Install uv for fast dependency installation
RUN pip install uv --no-cache-dir

COPY pyproject.toml .
RUN uv pip install --system --no-cache .

COPY . .

# Run database migrations then start the server
CMD ["sh", "-c", "alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 8000"]
