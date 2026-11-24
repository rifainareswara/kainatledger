import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/locale_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/money_text.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  final String? initialWalletId;
  const TransactionsPage({super.key, this.initialWalletId});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialWalletId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(transactionFilterProvider.notifier).update(
              (s) => s.copyWith(walletId: widget.initialWalletId),
            );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(transactionFilterProvider);
    final txAsync = ref.watch(transactionsProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          strings.navTransactions,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Search & Filter Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: strings.searchTransactions,
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(transactionFilterProvider.notifier).update(
                                        (s) => s.copyWith(search: ''),
                                      );
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        ref.read(transactionFilterProvider.notifier).update(
                              (s) => s.copyWith(search: val.trim()),
                            );
                      },
                    ),
                    const Gap(12),
                    // Filter Chips (All, Income, Expenses)
                    Row(
                      children: [
                        _PillFilterChip(
                          label: strings.all,
                          isSelected: filter.type == null,
                          onTap: () => ref
                              .read(transactionFilterProvider.notifier)
                              .update((s) => s.copyWith(clearType: true)),
                        ),
                        const Gap(8),
                        _PillFilterChip(
                          label: strings.income,
                          isSelected: filter.type == 'income',
                          onTap: () => ref
                              .read(transactionFilterProvider.notifier)
                              .update((s) => s.copyWith(type: 'income')),
                        ),
                        const Gap(8),
                        _PillFilterChip(
                          label: strings.expenses,
                          isSelected: filter.type == 'expense',
                          onTap: () => ref
                              .read(transactionFilterProvider.notifier)
                              .update((s) => s.copyWith(type: 'expense')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // Transaction Feed
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(transactionsProvider);
                  },
                  child: txAsync.when(
                    data: (txList) {
                      if (txList.items.isEmpty) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: EmptyStateWidget(
                              icon: Icons.receipt_long,
                              title: 'No Transactions',
                              message: 'No transactions found for the selected filter.',
                              actionLabel: 'Add Transaction',
                              onAction: () => context.go('/transactions/new?type=expense'),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 135),
                        itemCount: txList.items.length,
                        separatorBuilder: (_, __) => const Gap(10),
                        itemBuilder: (ctx, index) {
                          final tx = txList.items[index];
                          final isExpense = tx.type == 'expense';

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.015),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isExpense ? AppColors.expenseLight : AppColors.incomeLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    isExpense ? '-' : '+',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: isExpense ? AppColors.expense : AppColors.income,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                tx.category.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                '${tx.wallet.name} • ${formatDate(tx.date)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: MoneyText(
                                amount: tx.amount,
                                style: isExpense ? MoneyStyle.expense : MoneyStyle.income,
                                showPrefix: true,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => ErrorViewWidget(
                      message: 'Gagal memuat transaksi',
                      onRetry: () => ref.invalidate(transactionsProvider),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
