import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

enum MoneyStyle { neutral, income, expense, auto }

class MoneyText extends StatelessWidget {
  final num amount;
  final MoneyStyle style;
  final TextStyle? textStyle;
  final bool showPrefix;
  final bool compact;

  const MoneyText({
    super.key,
    required this.amount,
    this.style = MoneyStyle.neutral,
    this.textStyle,
    this.showPrefix = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String prefix = '';

    switch (style) {
      case MoneyStyle.income:
        color = AppColors.income;
        if (showPrefix && amount > 0) prefix = '+';
        break;
      case MoneyStyle.expense:
        color = AppColors.expense;
        if (showPrefix && amount > 0) prefix = '-';
        break;
      case MoneyStyle.auto:
        if (amount > 0) {
          color = AppColors.income;
          if (showPrefix) prefix = '+';
        } else if (amount < 0) {
          color = AppColors.expense;
          if (showPrefix) prefix = '-';
        } else {
          color = AppColors.textPrimary;
        }
        break;
      case MoneyStyle.neutral:
        color = textStyle?.color ?? AppColors.textPrimary;
        break;
    }

    final formatted = compact
        ? formatCurrencyCompact(amount.abs())
        : formatCurrency(amount.abs());

    return Text(
      '$prefix$formatted',
      style: (textStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
          .copyWith(color: color),
    );
  }
}
