# Import all models here so Alembic can detect them for autogenerate
from app.models.user import User, RefreshToken  # noqa: F401
from app.models.category import Category  # noqa: F401
from app.models.wallet import Wallet  # noqa: F401
from app.models.transaction import Transaction  # noqa: F401
from app.models.transfer import Transfer  # noqa: F401
