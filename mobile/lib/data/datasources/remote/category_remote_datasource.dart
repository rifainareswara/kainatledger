import 'package:dio/dio.dart';
import '../../models/category_model.dart';

class CategoryRemoteDataSource {
  final Dio _dio;
  const CategoryRemoteDataSource(this._dio);

  Future<List<CategoryModel>> getCategories({String? type}) async {
    final response = await _dio.get(
      '/categories',
      queryParameters: type != null ? {'type': type} : null,
    );
    return (response.data as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryModel> createCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
  }) async {
    final response = await _dio.post('/categories', data: {
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    });
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CategoryModel> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? color,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (icon != null) data['icon'] = icon;
    if (color != null) data['color'] = color;
    final response = await _dio.put('/categories/$id', data: data);
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete('/categories/$id');
  }
}
