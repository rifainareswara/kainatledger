import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/dummy_data.dart';
import '../../domain/entities/wallet_entity.dart';
import 'repository_providers.dart';

final walletsProvider = FutureProvider<List<WalletEntity>>((ref) async {
  try {
    final repo = ref.watch(walletRepositoryProvider);
    final result = await repo.getWallets();
    if (result.isNotEmpty) return result;
    return DummyData.wallets;
  } catch (e) {
    debugPrint('walletsProvider error, fallback to dummy data: $e');
    return DummyData.wallets;
  }
});

final walletSummaryProvider = FutureProvider<WalletSummaryEntity>((ref) async {
  try {
    final repo = ref.watch(walletRepositoryProvider);
    return await repo.getWalletSummary();
  } catch (e) {
    debugPrint('walletSummaryProvider error, fallback to dummy data: $e');
    return DummyData.walletSummary;
  }
});

class WalletActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  WalletActionsNotifier(this._ref) : super(const AsyncData(null));

  Future<bool> createWallet({
    required String name,
    required String type,
    required double initialBalance,
    String currency = 'IDR',
    String color = '#4A90E2',
    String icon = 'wallet',
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(walletRepositoryProvider);
      await repo.createWallet(
        name: name,
        type: type,
        initialBalance: initialBalance,
        currency: currency,
        color: color,
        icon: icon,
      );
    } catch (e) {
      debugPrint('createWallet API failed, fallback to DummyData: $e');
      DummyData.addWallet(
        name: name,
        type: type,
        initialBalance: initialBalance,
        color: color,
        icon: icon,
      );
    }
    _ref.invalidate(walletsProvider);
    _ref.invalidate(walletSummaryProvider);
    state = const AsyncData(null);
    return true;
  }

  Future<bool> updateWallet({
    required String id,
    String? name,
    String? color,
    String? icon,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(walletRepositoryProvider);
      await repo.updateWallet(id: id, name: name, color: color, icon: icon);
      _ref.invalidate(walletsProvider);
      _ref.invalidate(walletSummaryProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deactivateWallet(String id) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(walletRepositoryProvider);
      await repo.deactivateWallet(id);
      _ref.invalidate(walletsProvider);
      _ref.invalidate(walletSummaryProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> transfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    double fee = 0,
    required DateTime date,
    String? note,
  }) async {
    state = const AsyncLoading();
    try {
      final transferRepo = _ref.read(transferRepositoryProvider);
      await transferRepo.createTransfer(
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        fee: fee,
        date: date,
        note: note,
      );
    } catch (e) {
      debugPrint('transfer API failed, fallback to DummyData: $e');
      DummyData.performTransfer(
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        fee: fee,
        note: note,
      );
    }
    _ref.invalidate(walletsProvider);
    _ref.invalidate(walletSummaryProvider);
    state = const AsyncData(null);
    return true;
  }
}

final walletActionsProvider =
    StateNotifierProvider<WalletActionsNotifier, AsyncValue<void>>((ref) {
  return WalletActionsNotifier(ref);
});
