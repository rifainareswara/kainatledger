// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      balance: json['balance'] as String,
      currency: json['currency'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'balance': instance.balance,
      'currency': instance.currency,
      'color': instance.color,
      'icon': instance.icon,
      'is_active': instance.isActive,
    };

WalletSummaryModel _$WalletSummaryModelFromJson(Map<String, dynamic> json) =>
    WalletSummaryModel(
      totalBalance: json['total_balance'] as String,
      currency: json['currency'] as String,
      walletCount: (json['wallet_count'] as num).toInt(),
      wallets: (json['wallets'] as List<dynamic>)
          .map((e) => WalletModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WalletSummaryModelToJson(WalletSummaryModel instance) =>
    <String, dynamic>{
      'total_balance': instance.totalBalance,
      'currency': instance.currency,
      'wallet_count': instance.walletCount,
      'wallets': instance.wallets,
    };
