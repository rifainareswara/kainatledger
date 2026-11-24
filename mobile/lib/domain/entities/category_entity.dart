class CategoryEntity {
  final String id;
  final String name;
  final String type; // "income" | "expense"
  final String icon;
  final String color;
  final bool isDefault;
  final int transactionCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.transactionCount,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}
