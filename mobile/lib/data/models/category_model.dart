import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  final String id;
  final String name;
  final String type;
  final String icon;
  final String color;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @JsonKey(name: 'transaction_count', defaultValue: 0)
  final int transactionCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.transactionCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        name: name,
        type: type,
        icon: icon,
        color: color,
        isDefault: isDefault,
        transactionCount: transactionCount,
      );
}
