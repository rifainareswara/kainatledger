import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/dummy_data.dart';
import '../../domain/entities/report_entity.dart';
import 'repository_providers.dart';

class ReportFilterState {
  final int year;
  final int month;
  final String categoryType; // 'expense' or 'income'

  const ReportFilterState({
    required this.year,
    required this.month,
    this.categoryType = 'expense',
  });

  ReportFilterState copyWith({
    int? year,
    int? month,
    String? categoryType,
  }) {
    return ReportFilterState(
      year: year ?? this.year,
      month: month ?? this.month,
      categoryType: categoryType ?? this.categoryType,
    );
  }
}

final reportFilterProvider = StateProvider<ReportFilterState>((ref) {
  final now = DateTime.now();
  return ReportFilterState(year: now.year, month: now.month);
});

final reportSummaryProvider = FutureProvider<ReportSummaryEntity>((ref) async {
  try {
    final repo = ref.watch(reportRepositoryProvider);
    final filter = ref.watch(reportFilterProvider);
    return await repo.getSummary(year: filter.year, month: filter.month);
  } catch (e) {
    debugPrint('reportSummaryProvider error, fallback to dummy data: $e');
    return DummyData.reportSummary;
  }
});

final monthlyReportProvider =
    FutureProvider<List<MonthlyDataEntity>>((ref) async {
  try {
    final repo = ref.watch(reportRepositoryProvider);
    final filter = ref.watch(reportFilterProvider);
    return await repo.getMonthlyReport(year: filter.year);
  } catch (e) {
    debugPrint('monthlyReportProvider error, fallback to dummy data: $e');
    return DummyData.monthlyData;
  }
});

final categoryReportProvider =
    FutureProvider<List<CategoryBreakdownEntity>>((ref) async {
  try {
    final repo = ref.watch(reportRepositoryProvider);
    final filter = ref.watch(reportFilterProvider);

    final startDate = DateTime(filter.year, filter.month, 1);
    final endDate = DateTime(filter.year, filter.month + 1, 0);

    final result = await repo.getCategoryReport(
      type: filter.categoryType,
      dateFrom: startDate,
      dateTo: endDate,
    );
    if (result.isNotEmpty) return result;
    return DummyData.getCategoryBreakdown(filter.categoryType);
  } catch (e) {
    debugPrint('categoryReportProvider error, fallback to dummy data: $e');
    final filter = ref.watch(reportFilterProvider);
    return DummyData.getCategoryBreakdown(filter.categoryType);
  }
});
