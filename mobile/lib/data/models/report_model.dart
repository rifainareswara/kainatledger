import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/report_entity.dart';

part 'report_model.g.dart';

@JsonSerializable()
class ReportSummaryModel {
  final Map<String, dynamic> period;
  @JsonKey(name: 'total_balance')
  final String totalBalance;
  final String income;
  final String expense;
  final String net;

  const ReportSummaryModel({
    required this.period,
    required this.totalBalance,
    required this.income,
    required this.expense,
    required this.net,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSummaryModelToJson(this);

  ReportSummaryEntity toEntity() => ReportSummaryEntity(
        year: (period['year'] as num).toInt(),
        month: (period['month'] as num).toInt(),
        totalBalance: double.tryParse(totalBalance) ?? 0,
        income: double.tryParse(income) ?? 0,
        expense: double.tryParse(expense) ?? 0,
        net: double.tryParse(net) ?? 0,
      );
}

@JsonSerializable()
class MonthlyDataModel {
  final int month;
  @JsonKey(name: 'month_name')
  final String monthName;
  final String income;
  final String expense;

  const MonthlyDataModel({
    required this.month,
    required this.monthName,
    required this.income,
    required this.expense,
  });

  factory MonthlyDataModel.fromJson(Map<String, dynamic> json) =>
      _$MonthlyDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyDataModelToJson(this);

  MonthlyDataEntity toEntity() => MonthlyDataEntity(
        month: month,
        monthName: monthName,
        income: double.tryParse(income) ?? 0,
        expense: double.tryParse(expense) ?? 0,
      );
}

@JsonSerializable()
class CategoryBreakdownModel {
  @JsonKey(name: 'category_id')
  final String categoryId;
  @JsonKey(name: 'category_name')
  final String categoryName;
  final String icon;
  final String color;
  final String amount;
  final double percentage;
  @JsonKey(name: 'transaction_count')
  final int transactionCount;

  const CategoryBreakdownModel({
    required this.categoryId,
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryBreakdownModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryBreakdownModelToJson(this);

  CategoryBreakdownEntity toEntity() => CategoryBreakdownEntity(
        categoryId: categoryId,
        categoryName: categoryName,
        icon: icon,
        color: color,
        amount: double.tryParse(amount) ?? 0,
        percentage: percentage,
        transactionCount: transactionCount,
      );
}
