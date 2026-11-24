// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportSummaryModel _$ReportSummaryModelFromJson(Map<String, dynamic> json) =>
    ReportSummaryModel(
      period: json['period'] as Map<String, dynamic>,
      totalBalance: json['total_balance'] as String,
      income: json['income'] as String,
      expense: json['expense'] as String,
      net: json['net'] as String,
    );

Map<String, dynamic> _$ReportSummaryModelToJson(ReportSummaryModel instance) =>
    <String, dynamic>{
      'period': instance.period,
      'total_balance': instance.totalBalance,
      'income': instance.income,
      'expense': instance.expense,
      'net': instance.net,
    };

MonthlyDataModel _$MonthlyDataModelFromJson(Map<String, dynamic> json) =>
    MonthlyDataModel(
      month: (json['month'] as num).toInt(),
      monthName: json['month_name'] as String,
      income: json['income'] as String,
      expense: json['expense'] as String,
    );

Map<String, dynamic> _$MonthlyDataModelToJson(MonthlyDataModel instance) =>
    <String, dynamic>{
      'month': instance.month,
      'month_name': instance.monthName,
      'income': instance.income,
      'expense': instance.expense,
    };

CategoryBreakdownModel _$CategoryBreakdownModelFromJson(
        Map<String, dynamic> json) =>
    CategoryBreakdownModel(
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      amount: json['amount'] as String,
      percentage: (json['percentage'] as num).toDouble(),
      transactionCount: (json['transaction_count'] as num).toInt(),
    );

Map<String, dynamic> _$CategoryBreakdownModelToJson(
        CategoryBreakdownModel instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'icon': instance.icon,
      'color': instance.color,
      'amount': instance.amount,
      'percentage': instance.percentage,
      'transaction_count': instance.transactionCount,
    };
