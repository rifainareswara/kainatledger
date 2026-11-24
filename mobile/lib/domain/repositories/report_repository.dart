import 'dart:typed_data';
import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<ReportSummaryEntity> getSummary({required int year, required int month});
  Future<List<MonthlyDataEntity>> getMonthlyReport({required int year});
  Future<List<CategoryBreakdownEntity>> getCategoryReport({
    required String type,
    required DateTime dateFrom,
    required DateTime dateTo,
  });
  Future<Uint8List> exportCsv({required DateTime dateFrom, required DateTime dateTo});
  Future<Uint8List> exportExcel({required DateTime dateFrom, required DateTime dateTo});
}
