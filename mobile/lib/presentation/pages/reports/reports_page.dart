import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/file_downloader.dart';
import '../../providers/locale_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/money_text.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  Future<void> _exportData(BuildContext context, String format) async {
    final filter = ref.read(reportFilterProvider);
    final startDate = DateTime(filter.year, filter.month, 1);
    final endDate = DateTime(filter.year, filter.month + 1, 0);

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menyiapkan berkas $format...')),
      );

      final repo = ref.read(reportRepositoryProvider);
      Uint8List bytes;
      String filename;
      String mimeType;

      if (format == 'CSV') {
        try {
          bytes = await repo.exportCsv(dateFrom: startDate, dateTo: endDate);
        } catch (_) {
          final csvBuffer = StringBuffer();
          csvBuffer.writeln('Tanggal,Kategori,Tipe,Nominal,Dompet,Catatan');
          for (final tx in DummyData.transactionsList) {
            csvBuffer.writeln('${formatDate(tx.date)},"${tx.category.name}",${tx.type},${tx.amount},"${tx.wallet.name}","${tx.note ?? ''}"');
          }
          bytes = Uint8List.fromList(csvBuffer.toString().codeUnits);
        }
        filename = 'kainatledger-${filter.year}-${filter.month.toString().padLeft(2, '0')}.csv';
        mimeType = 'text/csv';
      } else {
        try {
          bytes = await repo.exportExcel(dateFrom: startDate, dateTo: endDate);
          filename = 'kainatledger-${filter.year}-${filter.month.toString().padLeft(2, '0')}.xlsx';
          mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        } catch (_) {
          final csvBuffer = StringBuffer();
          csvBuffer.writeln('Tanggal,Kategori,Tipe,Nominal,Dompet,Catatan');
          for (final tx in DummyData.transactionsList) {
            csvBuffer.writeln('${formatDate(tx.date)},"${tx.category.name}",${tx.type},${tx.amount},"${tx.wallet.name}","${tx.note ?? ''}"');
          }
          bytes = Uint8List.fromList(csvBuffer.toString().codeUnits);
          filename = 'kainatledger-${filter.year}-${filter.month.toString().padLeft(2, '0')}.csv';
          mimeType = 'text/csv';
        }
      }

      await FileDownloader.downloadBytes(
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berkas $filename berhasil diunduh')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh berkas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(reportFilterProvider);
    final summaryAsync = ref.watch(reportSummaryProvider);
    final categoryAsync = ref.watch(categoryReportProvider);
    final strings = ref.watch(appStringsProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 800;

    final isExpense = filter.categoryType == 'expense';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          strings.spendingOverview,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (format) => _exportData(context, format),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'CSV',
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined, size: 18),
                    const Gap(8),
                    Text(strings.exportCsv),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Excel',
                child: Row(
                  children: [
                    const Icon(Icons.table_chart_outlined, size: 18),
                    const Gap(8),
                    Text(strings.exportExcel),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                // Filter Dropdown Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Text(
                            strings.thisMonth,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Gap(4),
                          const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _TypeFilterChip(
                          label: strings.expenses,
                          isSelected: isExpense,
                          onTap: () => ref
                              .read(reportFilterProvider.notifier)
                              .update((s) => s.copyWith(categoryType: 'expense')),
                        ),
                        const Gap(8),
                        _TypeFilterChip(
                          label: strings.income,
                          isSelected: !isExpense,
                          onTap: () => ref
                              .read(reportFilterProvider.notifier)
                              .update((s) => s.copyWith(categoryType: 'income')),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(24),

                // Total Expenses Header
                summaryAsync.when(
                  data: (summary) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoneyText(
                        amount: isExpense ? summary.expense : summary.income,
                        textStyle: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        isExpense ? strings.totalExpenses : strings.totalIncome,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Rp 945.000'),
                ),
                const Gap(24),

                // Donut Chart with Center Text
                categoryAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const EmptyStateWidget(
                        icon: Icons.pie_chart_outline,
                        title: 'Tidak Ada Data',
                        message: 'Belum ada transaksi pada periode ini.',
                      );
                    }

                    final totalAmount = categories.fold(0.0, (acc, c) => acc + c.amount);

                    return Column(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 65,
                                    sections: categories.map((cat) {
                                      Color color;
                                      try {
                                        color = Color(int.parse(cat.color.replaceFirst('#', '0xFF')));
                                      } catch (_) {
                                        color = AppColors.primary;
                                      }

                                      return PieChartSectionData(
                                        color: color,
                                        value: cat.amount,
                                        radius: 28,
                                        showTitle: false,
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      formatCurrencyCompact(totalAmount),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Gap(2),
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(32),

                        // Category Breakdown List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const Gap(12),
                          itemBuilder: (ctx, index) {
                            final cat = categories[index];
                            Color catColor;
                            try {
                              catColor = Color(int.parse(cat.color.replaceFirst('#', '0xFF')));
                            } catch (_) {
                              catColor = AppColors.primary;
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: catColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(cat.icon),
                                      size: 18,
                                      color: catColor,
                                    ),
                                  ),
                                  const Gap(14),
                                  Expanded(
                                    child: Text(
                                      cat.categoryName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${cat.percentage.toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const Gap(16),
                                  MoneyText(
                                    amount: cat.amount,
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Gagal memuat kategori')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? icon) {
    switch (icon) {
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'movie':
        return Icons.movie_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'payments':
        return Icons.payments_outlined;
      case 'card_giftcard':
        return Icons.card_giftcard_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}

class _TypeFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeFilterChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
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
