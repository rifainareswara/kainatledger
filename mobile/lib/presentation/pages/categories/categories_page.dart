import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/category_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/glass_plus_button.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(BuildContext context, String defaultType) {
    final nameController = TextEditingController();
    String selectedType = defaultType;
    String selectedColor = '#2563EB';
    String selectedIcon = 'category';

    final List<String> iconOptions = [
      'restaurant',
      'shopping_bag',
      'directions_car',
      'receipt_long',
      'movie',
      'payments',
      'card_giftcard',
      'show_chart',
      'local_hospital',
      'school',
    ];

    final List<String> colorOptions = [
      '#2563EB',
      '#16A34A',
      '#DC2626',
      '#D97706',
      '#7C3AED',
      '#0D9488',
      '#EC4899',
      '#475569',
    ];

    showModalBottomSheet(
      context: rootNavigatorKey.currentContext ?? context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 30,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(bottomSheetCtx).viewInsets.bottom + 36,
            ),
            child: StatefulBuilder(
              builder: (ctx, setModalState) {
                return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tambah Kategori Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(bottomSheetCtx),
                        ),
                      ],
                    ),
                    const Gap(16),
                    // Type selector
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Pengeluaran')),
                            selected: selectedType == 'expense',
                            selectedColor: AppColors.expense,
                            labelStyle: TextStyle(
                              color: selectedType == 'expense'
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => selectedType = 'expense');
                            },
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Pemasukan')),
                            selected: selectedType == 'income',
                            selectedColor: AppColors.income,
                            labelStyle: TextStyle(
                              color: selectedType == 'income'
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => selectedType = 'income');
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    CustomTextField(
                      label: 'Nama Kategori',
                      hint: 'Contoh: Makanan & Minuman',
                      controller: nameController,
                      autofocus: true,
                    ),
                    const Gap(16),
                    const Text(
                      'Pilih Ikon',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: iconOptions.map((iconName) {
                        final isSelected = selectedIcon == iconName;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedIcon = iconName),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight : AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              _mapIcon(iconName),
                              size: 20,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Gap(16),
                    const Text(
                      'Pilih Warna Aksen',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const Gap(8),
                    Row(
                      children: colorOptions.map((hex) {
                        final isSelected = selectedColor == hex;
                        final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));

                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: GestureDetector(
                            onTap: () => setModalState(() => selectedColor = hex),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.black : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Gap(24),
                    CustomButton(
                      label: 'Simpan Kategori',
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) return;
                        final success = await ref
                            .read(categoryActionsProvider.notifier)
                            .createCategory(
                              name: nameController.text.trim(),
                              type: selectedType,
                              icon: selectedIcon,
                              color: selectedColor,
                            );
                        if (success && bottomSheetCtx.mounted) {
                          Navigator.pop(bottomSheetCtx);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Kelola Kategori',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList('expense'),
          _buildCategoryList('income'),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String type) {
    final categoriesAsync = ref.watch(categoriesProvider(type));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(categoriesProvider(type));
      },
      child: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: EmptyStateWidget(
                  icon: Icons.category,
                  title: 'Belum Ada Kategori',
                  message: 'Kategori membantu Anda mengelompokkan pos transaksi dengan rapi.',
                  actionLabel: 'Tambah Kategori Baru',
                  onAction: () => _showAddCategoryDialog(context, type),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Daftar Kategori (${categories.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GlassPlusButton(
                    size: 38,
                    onTap: () => _showAddCategoryDialog(context, type),
                    tooltip: type == 'expense'
                        ? 'Tambah Kategori Pengeluaran'
                        : 'Tambah Kategori Pemasukan',
                  ),
                ],
              ),
              const Gap(14),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const Gap(8),
                itemBuilder: (ctx, index) {
                  final cat = categories[index];
                  Color catColor;
                  try {
                    catColor = Color(int.parse(cat.color.replaceFirst('#', '0xFF')));
                  } catch (_) {
                    catColor = AppColors.primary;
                  }

                  return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_mapIcon(cat.icon), size: 20, color: catColor),
                  ),
                  title: Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${cat.transactionCount} transaksi',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: cat.isDefault
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'Sistem',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                          onPressed: () async {
                            if (cat.transactionCount > 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Kategori tidak dapat dihapus karena masih digunakan dalam transaksi.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogCtx) => AlertDialog(
                                title: const Text('Hapus Kategori'),
                                content: Text('Hapus kategori "${cat.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogCtx, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(dialogCtx, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ref
                                  .read(categoryActionsProvider.notifier)
                                  .deleteCategory(cat.id);
                            }
                          },
                        ),
                ),
              );
            },
          ),
        ],
      );
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (err, _) => ErrorViewWidget(
          message: 'Gagal memuat kategori',
          onRetry: () => ref.invalidate(categoriesProvider(type)),
        ),
      ),
    );
  }

  static IconData _mapIcon(String name) {
    switch (name.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'directions_car':
        return Icons.directions_car;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'movie':
        return Icons.movie;
      case 'payments':
        return Icons.payments;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'show_chart':
        return Icons.show_chart;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}
