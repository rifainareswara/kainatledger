import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transfer_entity.dart' as entity;

part 'transfer_model.g.dart';

@JsonSerializable()
class TransferWalletBriefModel {
  final String id;
  final String name;
  final String balance;

  const TransferWalletBriefModel({
    required this.id,
    required this.name,
    required this.balance,
  });

  factory TransferWalletBriefModel.fromJson(Map<String, dynamic> json) =>
      _$TransferWalletBriefModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransferWalletBriefModelToJson(this);

  entity.WalletBriefEntity toEntity() => entity.WalletBriefEntity(
        id: id,
        name: name,
        balance: double.tryParse(balance) ?? 0,
      );
}

@JsonSerializable()
class TransferModel {
  final String id;
  @JsonKey(name: 'from_wallet')
  final TransferWalletBriefModel fromWallet;
  @JsonKey(name: 'to_wallet')
  final TransferWalletBriefModel toWallet;
  final String amount;
  final String fee;
  final String date;
  final String? note;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const TransferModel({
    required this.id,
    required this.fromWallet,
    required this.toWallet,
    required this.amount,
    required this.fee,
    required this.date,
    this.note,
    required this.createdAt,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) =>
      _$TransferModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransferModelToJson(this);

  entity.TransferEntity toEntity() => entity.TransferEntity(
        id: id,
        fromWallet: fromWallet.toEntity(),
        toWallet: toWallet.toEntity(),
        amount: double.tryParse(amount) ?? 0,
        fee: double.tryParse(fee) ?? 0,
        date: DateTime.tryParse(date) ?? DateTime.now(),
        note: note,
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      );
}
