import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories({String? type});
  Future<CategoryEntity> createCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
  });
  Future<CategoryEntity> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? color,
  });
  Future<void> deleteCategory(String id);
}
