import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/dummy_data.dart';
import '../../domain/entities/category_entity.dart';
import 'repository_providers.dart';

final categoriesProvider =
    FutureProvider.family<List<CategoryEntity>, String?>((ref, type) async {
  try {
    final repo = ref.watch(categoryRepositoryProvider);
    final result = await repo.getCategories(type: type);
    if (result.isNotEmpty) return result;
    return DummyData.getCategories(type);
  } catch (e) {
    debugPrint('categoriesProvider error, fallback to dummy data: $e');
    return DummyData.getCategories(type);
  }
});

class CategoryActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  CategoryActionsNotifier(this._ref) : super(const AsyncData(null));

  Future<bool> createCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      await repo.createCategory(
        name: name,
        type: type,
        icon: icon,
        color: color,
      );
    } catch (e) {
      debugPrint('createCategory API failed, fallback to DummyData: $e');
      DummyData.addCategory(
        name: name,
        type: type,
        icon: icon,
        color: color,
      );
    }
    _ref.invalidate(categoriesProvider);
    state = const AsyncData(null);
    return true;
  }

  Future<bool> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? color,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      await repo.updateCategory(id: id, name: name, icon: icon, color: color);
      _ref.invalidate(categoriesProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      await repo.deleteCategory(id);
    } catch (e) {
      debugPrint('deleteCategory API failed, fallback to DummyData: $e');
      DummyData.deleteCategory(id);
    }
    _ref.invalidate(categoriesProvider);
    state = const AsyncData(null);
    return true;
  }
}

final categoryActionsProvider =
    StateNotifierProvider<CategoryActionsNotifier, AsyncValue<void>>((ref) {
  return CategoryActionsNotifier(ref);
});
