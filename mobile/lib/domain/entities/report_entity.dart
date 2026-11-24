class ReportSummaryEntity {
  final int year;
  final int month;
  final double totalBalance;
  final double income;
  final double expense;
  final double net;

  const ReportSummaryEntity({
    required this.year,
    required this.month,
    required this.totalBalance,
    required this.income,
    required this.expense,
    required this.net,
  });
}

class MonthlyDataEntity {
  final int month;
  final String monthName;
  final double income;
  final double expense;

  const MonthlyDataEntity({
    required this.month,
    required this.monthName,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;
}

class CategoryBreakdownEntity {
  final String categoryId;
  final String categoryName;
  final String icon;
  final String color;
  final double amount;
  final double percentage;
  final int transactionCount;

  const CategoryBreakdownEntity({
    required this.categoryId,
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}
