class CategoryBriefEntity {
  final String id;
  final String name;
  final String icon;
  final String color;

  const CategoryBriefEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class WalletBriefEntity {
  final String id;
  final String name;
  final String type;

  const WalletBriefEntity({
    required this.id,
    required this.name,
    required this.type,
  });
}

class TransactionEntity {
  final String id;
  final double amount;
  final String type; // "income" | "expense"
  final DateTime date;
  final String? note;
  final String? paymentMethod;
  final CategoryBriefEntity category;
  final WalletBriefEntity wallet;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.paymentMethod,
    required this.category,
    required this.wallet,
    required this.createdAt,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}

class TransactionListEntity {
  final List<TransactionEntity> items;
  final int total;
  final int page;
  final int size;
  final int pages;

  const TransactionListEntity({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });

  bool get hasNextPage => page < pages;
}
