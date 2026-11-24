import uuid
from typing import Optional

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import ForbiddenException, NotFoundException, UnprocessableException
from app.models.category import Category
from app.models.transaction import Transaction
from app.schemas.category import CategoryCreate, CategoryResponse, CategoryUpdate


DEFAULT_CATEGORIES = [
    {"name": "Makanan & Minuman", "type": "expense", "icon": "restaurant", "color": "#DC2626"},
    {"name": "Transportasi", "type": "expense", "icon": "directions_car", "color": "#D97706"},
    {"name": "Belanja", "type": "expense", "icon": "shopping_bag", "color": "#7C3AED"},
    {"name": "Tagihan & Utilitas", "type": "expense", "icon": "receipt_long", "color": "#2563EB"},
    {"name": "Hiburan", "type": "expense", "icon": "movie", "color": "#EC4899"},
    {"name": "Gaji", "type": "income", "icon": "payments", "color": "#16A34A"},
    {"name": "Bonus & Hadiah", "type": "income", "icon": "card_giftcard", "color": "#0D9488"},
    {"name": "Investasi", "type": "income", "icon": "show_chart", "color": "#2563EB"},
]


async def seed_default_categories(db: AsyncSession, user_id: uuid.UUID) -> None:
    for item in DEFAULT_CATEGORIES:
        cat = Category(
            user_id=user_id,
            name=item["name"],
            type=item["type"],
            icon=item["icon"],
            color=item["color"],
            is_default=True,
        )
        db.add(cat)
    await db.commit()


async def list_categories(
    db: AsyncSession, user_id: uuid.UUID, type_filter: Optional[str] = None
) -> list[CategoryResponse]:
    stmt = select(Category).where(Category.user_id == user_id)
    if type_filter:
        stmt = stmt.where(Category.type == type_filter)
    stmt = stmt.order_by(Category.name)

    rows = await db.scalars(stmt)
    categories = rows.all()

    # Count transactions per category in one query
    counts_stmt = (
        select(Transaction.category_id, func.count(Transaction.id).label("cnt"))
        .where(Transaction.user_id == user_id)
        .group_by(Transaction.category_id)
    )
    count_rows = await db.execute(counts_stmt)
    count_map = {str(row.category_id): row.cnt for row in count_rows}

    result = []
    for cat in categories:
        result.append(
            CategoryResponse(
                id=str(cat.id),
                name=cat.name,
                type=cat.type,
                icon=cat.icon,
                color=cat.color,
                is_default=cat.is_default,
                transaction_count=count_map.get(str(cat.id), 0),
            )
        )
    return result


async def create_category(
    db: AsyncSession, user_id: uuid.UUID, data: CategoryCreate
) -> CategoryResponse:
    cat = Category(
        user_id=user_id,
        name=data.name,
        type=data.type,
        icon=data.icon,
        color=data.color,
    )
    db.add(cat)
    await db.commit()
    await db.refresh(cat)
    return CategoryResponse(
        id=str(cat.id),
        name=cat.name,
        type=cat.type,
        icon=cat.icon,
        color=cat.color,
        is_default=cat.is_default,
        transaction_count=0,
    )


async def update_category(
    db: AsyncSession,
    user_id: uuid.UUID,
    category_id: uuid.UUID,
    data: CategoryUpdate,
) -> CategoryResponse:
    cat = await _get_owned(db, user_id, category_id)
    if data.name is not None:
        cat.name = data.name
    if data.icon is not None:
        cat.icon = data.icon
    if data.color is not None:
        cat.color = data.color
    await db.commit()
    await db.refresh(cat)

    count = await db.scalar(
        select(func.count(Transaction.id)).where(Transaction.category_id == cat.id)
    )
    return CategoryResponse(
        id=str(cat.id),
        name=cat.name,
        type=cat.type,
        icon=cat.icon,
        color=cat.color,
        is_default=cat.is_default,
        transaction_count=count or 0,
    )


async def delete_category(
    db: AsyncSession, user_id: uuid.UUID, category_id: uuid.UUID
) -> None:
    cat = await _get_owned(db, user_id, category_id)
    count = await db.scalar(
        select(func.count(Transaction.id)).where(Transaction.category_id == cat.id)
    )
    if count and count > 0:
        raise UnprocessableException(
            f"Cannot delete category with {count} existing transaction(s). "
            "Reassign or delete the transactions first."
        )
    await db.delete(cat)
    await db.commit()


async def _get_owned(
    db: AsyncSession, user_id: uuid.UUID, category_id: uuid.UUID
) -> Category:
    cat = await db.get(Category, category_id)
    if not cat:
        raise NotFoundException("Category")
    if cat.user_id != user_id:
        raise ForbiddenException()
    return cat
