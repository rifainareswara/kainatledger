import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/wallet_entity.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class WalletModel {
  final String id;
  final String name;
  final String type;
  final String balance;
  final String currency;
  final String color;
  final String icon;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.color,
    required this.icon,
    required this.isActive,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);

  WalletEntity toEntity() => WalletEntity(
        id: id,
        name: name,
        type: type,
        balance: double.tryParse(balance) ?? 0,
        currency: currency,
        color: color,
        icon: icon,
        isActive: isActive,
      );
}

@JsonSerializable()
class WalletSummaryModel {
  @JsonKey(name: 'total_balance')
  final String totalBalance;
  final String currency;
  @JsonKey(name: 'wallet_count')
  final int walletCount;
  final List<WalletModel> wallets;

  const WalletSummaryModel({
    required this.totalBalance,
    required this.currency,
    required this.walletCount,
    required this.wallets,
  });

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$WalletSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletSummaryModelToJson(this);

  WalletSummaryEntity toEntity() => WalletSummaryEntity(
        totalBalance: double.tryParse(totalBalance) ?? 0,
        currency: currency,
        walletCount: walletCount,
        wallets: wallets.map((w) => w.toEntity()).toList(),
      );
}
