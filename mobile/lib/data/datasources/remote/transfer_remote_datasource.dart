import 'package:dio/dio.dart';
import '../../models/transfer_model.dart';
import '../../models/report_model.dart';

class TransferRemoteDataSource {
  final Dio _dio;
  const TransferRemoteDataSource(this._dio);

  Future<List<TransferModel>> getTransfers({int page = 1, int size = 20}) async {
    final response = await _dio.get('/transfers', queryParameters: {
      'page': page,
      'size': size,
    });
    return (response.data['items'] as List)
        .map((e) => TransferModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TransferModel> createTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    double fee = 0,
    required String date,
    String? note,
  }) async {
    final data = <String, dynamic>{
      'from_wallet_id': fromWalletId,
      'to_wallet_id': toWalletId,
      'amount': amount,
      'fee': fee,
      'date': date,
    };
    if (note != null) data['note'] = note;
    final response = await _dio.post('/transfers', data: data);
    return TransferModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cancelTransfer(String id) async {
    await _dio.delete('/transfers/$id');
  }
}

class ReportRemoteDataSource {
  final Dio _dio;
  const ReportRemoteDataSource(this._dio);

  Future<ReportSummaryModel> getSummary({
    required int year,
    required int month,
  }) async {
    final response = await _dio.get('/reports/summary', queryParameters: {
      'year': year,
      'month': month,
    });
    return ReportSummaryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<MonthlyDataModel>> getMonthlyReport({required int year}) async {
    final response = await _dio.get('/reports/monthly', queryParameters: {
      'year': year,
    });
    return (response.data['data'] as List)
        .map((e) => MonthlyDataModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryBreakdownModel>> getCategoryReport({
    required String type,
    required String dateFrom,
    required String dateTo,
  }) async {
    final response = await _dio.get('/reports/by-category', queryParameters: {
      'type': type,
      'date_from': dateFrom,
      'date_to': dateTo,
    });
    return (response.data['items'] as List)
        .map((e) => CategoryBreakdownModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<int>> exportCsv({
    required String dateFrom,
    required String dateTo,
  }) async {
    final response = await _dio.get<List<int>>(
      '/reports/export/csv',
      queryParameters: {'date_from': dateFrom, 'date_to': dateTo},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? [];
  }

  Future<List<int>> exportExcel({
    required String dateFrom,
    required String dateTo,
  }) async {
    final response = await _dio.get<List<int>>(
      '/reports/export/excel',
      queryParameters: {'date_from': dateFrom, 'date_to': dateTo},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? [];
  }
}
