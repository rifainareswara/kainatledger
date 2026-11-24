import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<List<WalletEntity>> getWallets();
  Future<WalletSummaryEntity> getWalletSummary();
  Future<WalletEntity> getWallet(String id);
  Future<WalletEntity> createWallet({
    required String name,
    required String type,
    required double initialBalance,
    String currency,
    String color,
    String icon,
  });
  Future<WalletEntity> updateWallet({
    required String id,
    String? name,
    String? color,
    String? icon,
  });
  Future<void> deactivateWallet(String id);
}
