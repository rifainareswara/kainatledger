import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/remote/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remote;
  const WalletRepositoryImpl(this._remote);

  @override
  Future<List<WalletEntity>> getWallets() async {
    final models = await _remote.getWallets();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<WalletSummaryEntity> getWalletSummary() async {
    final model = await _remote.getWalletSummary();
    return model.toEntity();
  }

  @override
  Future<WalletEntity> getWallet(String id) async {
    final model = await _remote.getWallet(id);
    return model.toEntity();
  }

  @override
  Future<WalletEntity> createWallet({
    required String name,
    required String type,
    required double initialBalance,
    String currency = 'IDR',
    String color = '#4A90E2',
    String icon = 'wallet',
  }) async {
    final model = await _remote.createWallet(
      name: name, type: type, initialBalance: initialBalance,
      currency: currency, color: color, icon: icon,
    );
    return model.toEntity();
  }

  @override
  Future<WalletEntity> updateWallet({
    required String id,
    String? name,
    String? color,
    String? icon,
  }) async {
    final model = await _remote.updateWallet(
      id: id, name: name, color: color, icon: icon,
    );
    return model.toEntity();
  }

  @override
  Future<void> deactivateWallet(String id) => _remote.deactivateWallet(id);
}
