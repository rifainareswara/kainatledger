class WalletBriefEntity {
  final String id;
  final String name;
  final double balance;

  const WalletBriefEntity({
    required this.id,
    required this.name,
    required this.balance,
  });
}

class TransferEntity {
  final String id;
  final WalletBriefEntity fromWallet;
  final WalletBriefEntity toWallet;
  final double amount;
  final double fee;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const TransferEntity({
    required this.id,
    required this.fromWallet,
    required this.toWallet,
    required this.amount,
    required this.fee,
    required this.date,
    this.note,
    required this.createdAt,
  });
}
