import 'dart:typed_data';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/remote/transfer_remote_datasource.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferRemoteDataSource _remote;
  const TransferRepositoryImpl(this._remote);

  @override
  Future<List<TransferEntity>> getTransfers({int page = 1, int size = 20}) async {
    final models = await _remote.getTransfers(page: page, size: size);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TransferEntity> createTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    double fee = 0,
    required DateTime date,
    String? note,
  }) async {
    final model = await _remote.createTransfer(
      fromWalletId: fromWalletId,
      toWalletId: toWalletId,
      amount: amount,
      fee: fee,
      date: formatApiDate(date),
      note: note,
    );
    return model.toEntity();
  }

  @override
  Future<void> cancelTransfer(String id) => _remote.cancelTransfer(id);
}

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remote;
  const ReportRepositoryImpl(this._remote);

  @override
  Future<ReportSummaryEntity> getSummary({
    required int year,
    required int month,
  }) async {
    final model = await _remote.getSummary(year: year, month: month);
    return model.toEntity();
  }

  @override
  Future<List<MonthlyDataEntity>> getMonthlyReport({required int year}) async {
    final models = await _remote.getMonthlyReport(year: year);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CategoryBreakdownEntity>> getCategoryReport({
    required String type,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final models = await _remote.getCategoryReport(
      type: type,
      dateFrom: formatApiDate(dateFrom),
      dateTo: formatApiDate(dateTo),
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Uint8List> exportCsv({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final bytes = await _remote.exportCsv(
      dateFrom: formatApiDate(dateFrom),
      dateTo: formatApiDate(dateTo),
    );
    return Uint8List.fromList(bytes);
  }

  @override
  Future<Uint8List> exportExcel({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final bytes = await _remote.exportExcel(
      dateFrom: formatApiDate(dateFrom),
      dateTo: formatApiDate(dateTo),
    );
    return Uint8List.fromList(bytes);
  }
}
