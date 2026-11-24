// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryBriefModel _$CategoryBriefModelFromJson(Map<String, dynamic> json) =>
    CategoryBriefModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );

Map<String, dynamic> _$CategoryBriefModelToJson(CategoryBriefModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
    };

WalletBriefModel _$WalletBriefModelFromJson(Map<String, dynamic> json) =>
    WalletBriefModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$WalletBriefModelToJson(WalletBriefModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
    };

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      amount: json['amount'] as String,
      type: json['type'] as String,
      date: json['date'] as String,
      note: json['note'] as String?,
      paymentMethod: json['payment_method'] as String?,
      category:
          CategoryBriefModel.fromJson(json['category'] as Map<String, dynamic>),
      wallet: WalletBriefModel.fromJson(json['wallet'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'type': instance.type,
      'date': instance.date,
      'note': instance.note,
      'payment_method': instance.paymentMethod,
      'category': instance.category,
      'wallet': instance.wallet,
      'created_at': instance.createdAt,
    };

TransactionListModel _$TransactionListModelFromJson(
        Map<String, dynamic> json) =>
    TransactionListModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      pages: (json['pages'] as num).toInt(),
    );

Map<String, dynamic> _$TransactionListModelToJson(
        TransactionListModel instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'size': instance.size,
      'pages': instance.pages,
    };
