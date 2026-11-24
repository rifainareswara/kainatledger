class WalletEntity {
  final String id;
  final String name;
  final String type; // cash | bank | e_wallet | credit_card | investment
  final double balance;
  final String currency;
  final String color;
  final String icon;
  final bool isActive;

  const WalletEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.color,
    required this.icon,
    required this.isActive,
  });
}

class WalletSummaryEntity {
  final double totalBalance;
  final String currency;
  final int walletCount;
  final List<WalletEntity> wallets;

  const WalletSummaryEntity({
    required this.totalBalance,
    required this.currency,
    required this.walletCount,
    required this.wallets,
  });
}
