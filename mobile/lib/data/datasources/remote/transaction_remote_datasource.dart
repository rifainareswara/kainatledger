import 'package:dio/dio.dart';
import '../../models/transaction_model.dart';

class TransactionRemoteDataSource {
  final Dio _dio;
  const TransactionRemoteDataSource(this._dio);

  Future<TransactionListModel> getTransactions({
    int page = 1,
    int size = 20,
    String? type,
    String? walletId,
    String? categoryId,
    String? dateFrom,
    String? dateTo,
    String? search,
    String sortBy = 'date',
    String sortOrder = 'desc',
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };
    if (type != null) params['type'] = type;
    if (walletId != null) params['wallet_id'] = walletId;
    if (categoryId != null) params['category_id'] = categoryId;
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    if (search != null) params['search'] = search;

    final response = await _dio.get('/transactions', queryParameters: params);
    return TransactionListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TransactionModel> getTransaction(String id) async {
    final response = await _dio.get('/transactions/$id');
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TransactionModel> createTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required String date,
    String? note,
    String? paymentMethod,
  }) async {
    final data = <String, dynamic>{
      'wallet_id': walletId,
      'category_id': categoryId,
      'amount': amount,
      'date': date,
    };
    if (note != null) data['note'] = note;
    if (paymentMethod != null) data['payment_method'] = paymentMethod;

    final response = await _dio.post('/transactions', data: data);
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TransactionModel> updateTransaction({
    required String id,
    String? walletId,
    String? categoryId,
    double? amount,
    String? date,
    String? note,
    String? paymentMethod,
  }) async {
    final data = <String, dynamic>{};
    if (walletId != null) data['wallet_id'] = walletId;
    if (categoryId != null) data['category_id'] = categoryId;
    if (amount != null) data['amount'] = amount;
    if (date != null) data['date'] = date;
    if (note != null) data['note'] = note;
    if (paymentMethod != null) data['payment_method'] = paymentMethod;

    final response = await _dio.put('/transactions/$id', data: data);
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete('/transactions/$id');
  }
}
