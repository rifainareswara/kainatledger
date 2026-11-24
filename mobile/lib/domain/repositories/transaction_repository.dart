import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
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
  });

  Future<TransactionEntity> getTransaction(String id);

  Future<TransactionEntity> createTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required DateTime date,
    String? note,
    String? paymentMethod,
  });

  Future<TransactionEntity> updateTransaction({
    required String id,
    String? walletId,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
    String? paymentMethod,
  });

  Future<void> deleteTransaction(String id);
}
