import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/dummy_data.dart';
import '../../domain/entities/transaction_entity.dart';
import 'repository_providers.dart';
import 'wallet_provider.dart';

class TransactionFilterState {
  final int page;
  final int size;
  final String? type;
  final String? walletId;
  final String? categoryId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? search;
  final String sortBy;
  final String sortOrder;

  const TransactionFilterState({
    this.page = 1,
    this.size = 20,
    this.type,
    this.walletId,
    this.categoryId,
    this.dateFrom,
    this.dateTo,
    this.search,
    this.sortBy = 'date',
    this.sortOrder = 'desc',
  });

  TransactionFilterState copyWith({
    int? page,
    int? size,
    String? type,
    String? walletId,
    String? categoryId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? search,
    String? sortBy,
    String? sortOrder,
    bool clearType = false,
    bool clearWallet = false,
    bool clearCategory = false,
    bool clearDates = false,
  }) {
    return TransactionFilterState(
      page: page ?? this.page,
      size: size ?? this.size,
      type: clearType ? null : (type ?? this.type),
      walletId: clearWallet ? null : (walletId ?? this.walletId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      dateFrom: clearDates ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDates ? null : (dateTo ?? this.dateTo),
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

final transactionFilterProvider = StateProvider<TransactionFilterState>((ref) {
  return const TransactionFilterState();
});

final transactionsProvider = FutureProvider<TransactionListEntity>((ref) async {
  try {
    final repo = ref.watch(transactionRepositoryProvider);
    final filter = ref.watch(transactionFilterProvider);

    final result = await repo.getTransactions(
      page: filter.page,
      size: filter.size,
      type: filter.type,
      walletId: filter.walletId,
      categoryId: filter.categoryId,
      dateFrom: filter.dateFrom,
      dateTo: filter.dateTo,
      search: filter.search,
      sortBy: filter.sortBy,
      sortOrder: filter.sortOrder,
    );
    if (result.items.isNotEmpty) return result;
    return DummyData.paginatedTransactions;
  } catch (e) {
    debugPrint('transactionsProvider error, fallback to dummy data: $e');
    return DummyData.paginatedTransactions;
  }
});

final recentTransactionsProvider =
    FutureProvider<TransactionListEntity>((ref) async {
  try {
    final repo = ref.watch(transactionRepositoryProvider);
    final result = await repo.getTransactions(page: 1, size: 5, sortOrder: 'desc');
    if (result.items.isNotEmpty) return result;
    return DummyData.recentTransactions;
  } catch (e) {
    debugPrint('recentTransactionsProvider error, fallback to dummy data: $e');
    return DummyData.recentTransactions;
  }
});

class TransactionActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  TransactionActionsNotifier(this._ref) : super(const AsyncData(null));

  Future<bool> createTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required DateTime date,
    String? note,
    String? paymentMethod,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(transactionRepositoryProvider);
      await repo.createTransaction(
        walletId: walletId,
        categoryId: categoryId,
        amount: amount,
        date: date,
        note: note,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      debugPrint('createTransaction API failed, fallback to DummyData: $e');
      DummyData.addTransaction(
        walletId: walletId,
        categoryId: categoryId,
        amount: amount,
        date: date,
        note: note,
        paymentMethod: paymentMethod,
      );
    }
    _ref.invalidate(transactionsProvider);
    _ref.invalidate(recentTransactionsProvider);
    _ref.invalidate(walletsProvider);
    _ref.invalidate(walletSummaryProvider);
    state = const AsyncData(null);
    return true;
  }

  Future<bool> updateTransaction({
    required String id,
    String? walletId,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
    String? paymentMethod,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(transactionRepositoryProvider);
      await repo.updateTransaction(
        id: id,
        walletId: walletId,
        categoryId: categoryId,
        amount: amount,
        date: date,
        note: note,
        paymentMethod: paymentMethod,
      );
      _ref.invalidate(transactionsProvider);
      _ref.invalidate(recentTransactionsProvider);
      _ref.invalidate(walletsProvider);
      _ref.invalidate(walletSummaryProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(transactionRepositoryProvider);
      await repo.deleteTransaction(id);
    } catch (e) {
      debugPrint('deleteTransaction API failed, fallback to DummyData: $e');
      DummyData.deleteTransaction(id);
    }
    _ref.invalidate(transactionsProvider);
    _ref.invalidate(recentTransactionsProvider);
    _ref.invalidate(walletsProvider);
    _ref.invalidate(walletSummaryProvider);
    state = const AsyncData(null);
    return true;
  }
}

final transactionActionsProvider =
    StateNotifierProvider<TransactionActionsNotifier, AsyncValue<void>>((ref) {
  return TransactionActionsNotifier(ref);
});
