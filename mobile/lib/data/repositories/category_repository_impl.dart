import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/remote/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remote;
  const CategoryRepositoryImpl(this._remote);

  @override
  Future<List<CategoryEntity>> getCategories({String? type}) async {
    final models = await _remote.getCategories(type: type);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CategoryEntity> createCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
  }) async {
    final model = await _remote.createCategory(
      name: name, type: type, icon: icon, color: color,
    );
    return model.toEntity();
  }

  @override
  Future<CategoryEntity> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? color,
  }) async {
    final model = await _remote.updateCategory(
      id: id, name: name, icon: icon, color: color,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteCategory(String id) => _remote.deleteCategory(id);
}
