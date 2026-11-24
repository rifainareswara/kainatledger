// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferWalletBriefModel _$TransferWalletBriefModelFromJson(
        Map<String, dynamic> json) =>
    TransferWalletBriefModel(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: json['balance'] as String,
    );

Map<String, dynamic> _$TransferWalletBriefModelToJson(
        TransferWalletBriefModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'balance': instance.balance,
    };

TransferModel _$TransferModelFromJson(Map<String, dynamic> json) =>
    TransferModel(
      id: json['id'] as String,
      fromWallet: TransferWalletBriefModel.fromJson(
          json['from_wallet'] as Map<String, dynamic>),
      toWallet: TransferWalletBriefModel.fromJson(
          json['to_wallet'] as Map<String, dynamic>),
      amount: json['amount'] as String,
      fee: json['fee'] as String,
      date: json['date'] as String,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$TransferModelToJson(TransferModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from_wallet': instance.fromWallet,
      'to_wallet': instance.toWallet,
      'amount': instance.amount,
      'fee': instance.fee,
      'date': instance.date,
      'note': instance.note,
      'created_at': instance.createdAt,
    };
