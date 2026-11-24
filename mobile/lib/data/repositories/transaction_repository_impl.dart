import '../../core/utils/date_formatter.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/remote/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remote;
  const TransactionRepositoryImpl(this._remote);

  @override
  Future<TransactionListEntity> getTransactions({
    int page = 1,
    int size = 20,
    String? type,
    String? walletId,
    String? categoryId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? search,
    String sortBy = 'date',
    String sortOrder = 'desc',
  }) async {
    final model = await _remote.getTransactions(
      page: page,
      size: size,
      type: type,
      walletId: walletId,
      categoryId: categoryId,
      dateFrom: dateFrom != null ? formatApiDate(dateFrom) : null,
      dateTo: dateTo != null ? formatApiDate(dateTo) : null,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
    return model.toEntity();
  }

  @override
  Future<TransactionEntity> getTransaction(String id) async {
    final model = await _remote.getTransaction(id);
    return model.toEntity();
  }

  @override
  Future<TransactionEntity> createTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required DateTime date,
    String? note,
    String? paymentMethod,
  }) async {
    final model = await _remote.createTransaction(
      walletId: walletId,
      categoryId: categoryId,
      amount: amount,
      date: formatApiDate(date),
      note: note,
      paymentMethod: paymentMethod,
    );
    return model.toEntity();
  }

  @override
  Future<TransactionEntity> updateTransaction({
    required String id,
    String? walletId,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
    String? paymentMethod,
  }) async {
    final model = await _remote.updateTransaction(
      id: id,
      walletId: walletId,
      categoryId: categoryId,
      amount: amount,
      date: date != null ? formatApiDate(date) : null,
      note: note,
      paymentMethod: paymentMethod,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteTransaction(String id) => _remote.deleteTransaction(id);
}
