import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transaction_entity.dart'
    as entity;

part 'transaction_model.g.dart';

@JsonSerializable()
class CategoryBriefModel {
  final String id;
  final String name;
  final String icon;
  final String color;

  const CategoryBriefModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory CategoryBriefModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryBriefModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryBriefModelToJson(this);

  entity.CategoryBriefEntity toEntity() => entity.CategoryBriefEntity(
        id: id,
        name: name,
        icon: icon,
        color: color,
      );
}

@JsonSerializable()
class WalletBriefModel {
  final String id;
  final String name;
  final String type;

  const WalletBriefModel({
    required this.id,
    required this.name,
    required this.type,
  });

  factory WalletBriefModel.fromJson(Map<String, dynamic> json) =>
      _$WalletBriefModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletBriefModelToJson(this);

  entity.WalletBriefEntity toEntity() => entity.WalletBriefEntity(
        id: id,
        name: name,
        type: type,
      );
}

@JsonSerializable()
class TransactionModel {
  final String id;
  final String amount;
  final String type;
  final String date;
  final String? note;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  final CategoryBriefModel category;
  final WalletBriefModel wallet;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.paymentMethod,
    required this.category,
    required this.wallet,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  entity.TransactionEntity toEntity() => entity.TransactionEntity(
        id: id,
        amount: double.tryParse(amount) ?? 0,
        type: type,
        date: DateTime.tryParse(date) ?? DateTime.now(),
        note: note,
        paymentMethod: paymentMethod,
        category: category.toEntity(),
        wallet: wallet.toEntity(),
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      );
}

@JsonSerializable()
class TransactionListModel {
  final List<TransactionModel> items;
  final int total;
  final int page;
  final int size;
  final int pages;

  const TransactionListModel({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });

  factory TransactionListModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionListModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionListModelToJson(this);

  entity.TransactionListEntity toEntity() => entity.TransactionListEntity(
        items: items.map((t) => t.toEntity()).toList(),
        total: total,
        page: page,
        size: size,
        pages: pages,
      );
}
