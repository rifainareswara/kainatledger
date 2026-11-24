import '../entities/transfer_entity.dart';

abstract class TransferRepository {
  Future<List<TransferEntity>> getTransfers({int page = 1, int size = 20});
  Future<TransferEntity> createTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    double fee = 0,
    required DateTime date,
    String? note,
  });
  Future<void> cancelTransfer(String id);
}
