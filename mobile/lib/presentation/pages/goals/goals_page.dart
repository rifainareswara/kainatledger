import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/locale_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/glass_plus_button.dart';

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  void _openAddGoalModal(BuildContext context) {
    final strings = ref.read(appStringsProvider);
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final currentController = TextEditingController();
    String selectedIcon = 'directions_car';
    String selectedColor = '#4F46E5';

    showModalBottomSheet(
      context: rootNavigatorKey.currentContext ?? context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
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
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 36,
          ),
          child: StatefulBuilder(
            builder: (modalCtx, setModalState) => SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strings.addGoalModalTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
                const Gap(16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: strings.goalName,
                    hintText: strings.goalNameHint,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const Gap(12),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: strings.targetAmount,
                    hintText: 'Contoh: 15000000',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const Gap(12),
                TextField(
                  controller: currentController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: strings.currentAmount,
                    hintText: 'Contoh: 3000000',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const Gap(16),
                Text(
                  strings.selectGoalIcon,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const Gap(8),
                Row(
                  children: [
                    _IconSelectorOption(
                      icon: Icons.directions_car,
                      name: 'directions_car',
                      isSelected: selectedIcon == 'directions_car',
                      onSelect: () => setModalState(() => selectedIcon = 'directions_car'),
                    ),
                    const Gap(10),
                    _IconSelectorOption(
                      icon: Icons.beach_access,
                      name: 'beach_access',
                      isSelected: selectedIcon == 'beach_access',
                      onSelect: () => setModalState(() => selectedIcon = 'beach_access'),
                    ),
                    const Gap(10),
                    _IconSelectorOption(
                      icon: Icons.security,
                      name: 'security',
                      isSelected: selectedIcon == 'security',
                      onSelect: () => setModalState(() => selectedIcon = 'security'),
                    ),
                    const Gap(10),
                    _IconSelectorOption(
                      icon: Icons.laptop_mac,
                      name: 'laptop_mac',
                      isSelected: selectedIcon == 'laptop_mac',
                      onSelect: () => setModalState(() => selectedIcon = 'laptop_mac'),
                    ),
                    const Gap(10),
                    _IconSelectorOption(
                      icon: Icons.home,
                      name: 'home',
                      isSelected: selectedIcon == 'home',
                      onSelect: () => setModalState(() => selectedIcon = 'home'),
                    ),
                  ],
                ),
                const Gap(24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final target = double.tryParse(targetController.text.trim()) ?? 0;
                    final current = double.tryParse(currentController.text.trim()) ?? 0;

                    if (title.isEmpty || target <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harap isi nama target dan nominal yang valid')),
                      );
                      return;
                    }

                    DummyData.addGoal(
                      title: title,
                      targetAmount: target,
                      currentAmount: current,
                      icon: selectedIcon,
                      color: selectedColor,
                    );

                    Navigator.pop(modalCtx);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Target "$title" berhasil disimpan!')),
                    );
                  },
                  child: Text(
                    strings.saveGoal,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 800;
    final goals = DummyData.goals;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          strings.goalsTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 32 : 16,
          vertical: 16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section with contextual Add Button (aligns cleanly like Wallets Page)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      strings.myGoals,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GlassPlusButton(
                      size: 38,
                      onTap: () => _openAddGoalModal(context),
                      tooltip: strings.isId ? 'Tambah Target Tabungan' : 'Add Savings Goal',
                    ),
                  ],
                ),
                const Gap(16),

                // Goals List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goals.length,
                  separatorBuilder: (_, __) => const Gap(14),
                  itemBuilder: (ctx, index) {
                    final goal = goals[index];
                    Color goalColor;
                    try {
                      goalColor = Color(int.parse(goal.color.replaceFirst('#', '0xFF')));
                    } catch (_) {
                      goalColor = AppColors.primary;
                    }

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: goalColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getGoalIcon(goal.icon),
                                  size: 22,
                                  color: goalColor,
                                ),
                              ),
                              const Gap(14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Gap(2),
                                    Text(
                                      '${strings.targetOf}: ${formatCurrency(goal.targetAmount)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${goal.percentage}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: goal.progress,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(goalColor),
                            ),
                          ),
                          const Gap(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${formatCurrency(goal.currentAmount)} / ${formatCurrency(goal.targetAmount)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${strings.remaining} ${formatCurrency((goal.targetAmount - goal.currentAmount).clamp(0, double.infinity))}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Gap(110),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getGoalIcon(String icon) {
    switch (icon) {
      case 'directions_car':
        return Icons.directions_car;
      case 'beach_access':
        return Icons.beach_access;
      case 'security':
        return Icons.shield_outlined;
      case 'laptop_mac':
        return Icons.laptop_mac;
      case 'home':
        return Icons.home_outlined;
      default:
        return Icons.star_border;
    }
  }
}

class _IconSelectorOption extends StatelessWidget {
  final IconData icon;
  final String name;
  final bool isSelected;
  final VoidCallback onSelect;

  const _IconSelectorOption({
    required this.icon,
    required this.name,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
