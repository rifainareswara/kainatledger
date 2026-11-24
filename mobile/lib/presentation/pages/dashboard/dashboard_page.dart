import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/bill_reminder.dart';
import '../../providers/bill_reminder_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_plus_button.dart';
import '../../widgets/money_text.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(walletSummaryProvider);
    final reportSummaryAsync = ref.watch(reportSummaryProvider);
    final recentTxAsync = ref.watch(recentTransactionsProvider);
    final urgentBills = ref.watch(urgentBillRemindersProvider);
    final unpaidCount = ref.watch(unpaidBillCountProvider);
    final profile = ref.watch(userProfileProvider);
    final strings = ref.watch(appStringsProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;
    final userName = profile.name;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(walletSummaryProvider);
            ref.invalidate(reportSummaryProvider);
            ref.invalidate(walletsProvider);
            ref.invalidate(recentTransactionsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              isWide ? 36.0 : 20.0,
              20.0,
              isWide ? 36.0 : 20.0,
              125.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header: Greeting + Notification Bell with red dot
                    _buildHeader(context, userName, strings, unpaidCount),
                    const Gap(16),

                    // 2. Urgent Bill Reminders Banner (due today or tomorrow)
                    if (urgentBills.isNotEmpty) ...[
                      _buildImpendingBillsBanner(context, urgentBills, strings),
                      const Gap(16),
                    ],

                    // 3. Main Content
                    if (isWide) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                _buildTotalBalanceCard(summaryAsync, strings),
                                const Gap(20),
                                _buildCircularActionButtons(context, strings),
                                const Gap(24),
                                _buildQuickOverviewCard(reportSummaryAsync, strings),
                              ],
                            ),
                          ),
                          const Gap(28),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRecentTxHeader(context, strings),
                                const Gap(12),
                                _buildRecentTransactionsList(recentTxAsync, strings),
                                const Gap(80),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildTotalBalanceCard(summaryAsync, strings),
                      const Gap(20),
                      _buildCircularActionButtons(context, strings),
                      const Gap(24),
                      _buildQuickOverviewCard(reportSummaryAsync, strings),
                      const Gap(24),
                      _buildRecentTxHeader(context, strings),
                      const Gap(12),
                      _buildRecentTransactionsList(recentTxAsync, strings),
                      const Gap(80),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, AppStrings strings, int unpaidCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Tooltip(
          message: strings.navProfile,
          child: InkWell(
            onTap: () => context.go('/profile'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'O',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('👋 ', style: TextStyle(fontSize: 14)),
                          Text(
                            '${strings.greetingHi}, $userName',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Gap(2),
                      Text(
                        strings.greetingTime,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Notification bell with unread badge (matching user screenshot)
        Tooltip(
          message: strings.billReminders,
          child: InkWell(
            onTap: () => _showBillRemindersModal(context, strings),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications,
                    size: 24,
                    color: Color(0xFF1E293B),
                  ),
                  if (unpaidCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImpendingBillsBanner(
    BuildContext context,
    List<BillReminder> urgentBills,
    AppStrings strings,
  ) {
    if (urgentBills.isEmpty) return const SizedBox.shrink();
    final topBill = urgentBills.first;
    final isToday = topBill.isDueToday;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isToday
              ? [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)]
              : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToday ? const Color(0xFFFCA5A5) : const Color(0xFFFCD34D),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isToday ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _showBillRemindersModal(context, strings),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: InkWell(
              onTap: () => _showBillRemindersModal(context, strings),
              borderRadius: BorderRadius.circular(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? strings.dueTodayAlert : strings.dueTomorrowAlert,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isToday ? const Color(0xFFB91C1C) : const Color(0xFFB45309),
                    ),
                  ),
                  const Gap(2),
                  Text(
                    '${topBill.title} • ${formatCurrency(topBill.amount)}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(10),
          InkWell(
            onTap: () async {
              await ref.read(billRemindersProvider.notifier).markAsPaid(topBill.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${topBill.title} ${strings.isId ? 'berhasil ditandai lunas!' : 'marked as paid!'}',
                    ),
                    backgroundColor: const Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (isToday ? const Color(0xFFDC2626) : const Color(0xFFD97706))
                        .withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                strings.markPaid,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(
    AsyncValue summaryAsync,
    AppStrings strings,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B0B33), // deep neon midnight purple
            Color(0xFF2E1065), // royal violet
            Color(0xFF4C1D95), // vibrant deep purple
            Color(0xFF6B21A8), // glowing violet edge
          ],
          stops: [0.0, 0.32, 0.72, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.26),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B21A8).withValues(alpha: 0.38),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: const Color(0xFF9333EA).withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background ambient glow and specular sweep
            Positioned.fill(
              child: CustomPaint(
                painter: _FintechGlassCardBackgroundPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Total Saldo label + Frosted Glass Eye Toggle Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        strings.totalBalance,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDDD6FE),
                          letterSpacing: 0.2,
                        ),
                      ),
                      // Frosted Glass Square Eye Toggle Button
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.32),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            _isBalanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 19,
                            color: Colors.white,
                          ),
                          onPressed: () =>
                              setState(() => _isBalanceVisible = !_isBalanceVisible),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),

                  // Total Balance Nominal Amount
                  summaryAsync.when(
                    data: (summary) => Text(
                      _isBalanceVisible ? formatCurrency(summary.totalBalance) : '••••••••',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 38,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    error: (_, __) => Text(
                      _isBalanceVisible ? 'Rp 25.104.000' : '••••••••',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const Gap(16),

                  // Frosted Percentage Pill: versus bulan lalu
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward, size: 13, color: Color(0xFF86EFAC)),
                        const Gap(5),
                        Text(
                          strings.vsLastMonth,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularActionButtons(BuildContext context, AppStrings strings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CircleActionButton(
          label: strings.send,
          icon: Icons.north_east,
          onTap: () => context.go('/transactions/new?type=expense'),
        ),
        _CircleActionButton(
          label: strings.receive,
          icon: Icons.south_west,
          onTap: () => context.go('/transactions/new?type=income'),
        ),
        _CircleActionButton(
          label: strings.more,
          icon: Icons.more_horiz,
          onTap: () => _showMoreActionsModal(context),
        ),
      ],
    );
  }

  Widget _buildQuickOverviewCard(AsyncValue reportSummaryAsync, AppStrings strings) {
    final report = reportSummaryAsync.valueOrNull ?? DummyData.reportSummary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.quickOverview,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.thisMonth,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Gap(4),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          _OverviewRowItem(
            title: strings.income,
            amount: report.income,
            icon: Icons.arrow_upward,
            iconColor: AppColors.income,
            bgColor: AppColors.incomeLight,
          ),
          const Gap(14),
          _OverviewRowItem(
            title: strings.expenses,
            amount: report.expense,
            icon: Icons.arrow_downward,
            iconColor: AppColors.expense,
            bgColor: AppColors.expenseLight,
          ),
          const Gap(14),
          _OverviewRowItem(
            title: strings.savings,
            amount: 8000000,
            icon: Icons.account_balance_wallet,
            iconColor: AppColors.savings,
            bgColor: AppColors.savingsLight,
          ),
          const Gap(14),
          _OverviewRowItem(
            title: strings.investments,
            amount: 8000000,
            icon: Icons.trending_up,
            iconColor: AppColors.investment,
            bgColor: AppColors.investmentLight,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTxHeader(BuildContext context, AppStrings strings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          strings.recentTransactions,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: () => context.go('/transactions'),
          child: Text(
            strings.viewAll,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsList(AsyncValue recentTxAsync, AppStrings strings) {
    return recentTxAsync.when(
      data: (txList) {
        if (txList.items.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: EmptyStateWidget(
              icon: Icons.receipt_long,
              title: strings.noTransactions,
              message: strings.noTransactionsDesc,
              actionLabel: strings.addTransaction,
              onAction: () => context.go('/transactions/new?type=expense'),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: txList.items.length,
            separatorBuilder: (_, __) => const Divider(
              color: AppColors.borderSoft,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (ctx, index) {
              final tx = txList.items[index];
              final isExpense = tx.type == 'expense';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                        fontSize: 20,
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
                    fontWeight: FontWeight.w600,
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
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const Center(child: Text('Gagal memuat transaksi')),
    );
  }

  void _showMoreActionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aksi Cepat & Navigasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const Gap(16),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
              title: const Text('Transfer Antar Dompet'),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/wallets/transfer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
              title: const Text('Kelola Semua Dompet'),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/wallets');
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart_outline, color: AppColors.primary),
              title: const Text('Target Keuangan'),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/goals');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
              title: const Text('Anggaran Bulanan'),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/budget');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBillRemindersModal(BuildContext context, AppStrings strings) {
    showModalBottomSheet(
      context: rootNavigatorKey.currentContext ?? context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final reminders = ref.watch(billRemindersProvider);
          final urgentCount = ref.watch(unpaidBillCountProvider);

          return SafeArea(
            top: false,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(ctx).height * 0.84,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: 1.5,
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 30,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 18, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF818CF8).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        strings.billReminders,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (urgentCount > 0) ...[
                                        const Gap(8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$urgentCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const Gap(2),
                                  Text(
                                    strings.billRemindersDesc,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Pure symbol add button (no text label!)
                            GlassPlusButton(
                              size: 38,
                              onTap: () => _showAddBillDialog(ctx, ref, strings),
                              tooltip: strings.addBillReminder,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),

                      // Notification permission reminder banner
                      Container(
                        margin: const EdgeInsets.fromLTRB(18, 10, 18, 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF16A34A)),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                strings.notificationsActive,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // List of bill reminders
                      Flexible(
                        child: reminders.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Center(
                                  child: Text(
                                    strings.noUpcomingBills,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                                itemCount: reminders.length,
                                separatorBuilder: (_, __) => const Gap(10),
                                itemBuilder: (c, idx) {
                                  final bill = reminders[idx];
                                  return _buildBillReminderItem(ctx, ref, bill, strings);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBillReminderItem(
    BuildContext context,
    WidgetRef ref,
    BillReminder bill,
    AppStrings strings,
  ) {
    final isId = strings.isId;
    final statusLabel = bill.getStatusLabel(isId: isId);

    Color statusColor;
    Color statusBg;
    if (bill.isPaid) {
      statusColor = const Color(0xFF16A34A);
      statusBg = const Color(0xFFDCFCE7);
    } else if (bill.isDueToday) {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEE2E2);
    } else if (bill.isDueTomorrow) {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFEF3C7);
    } else {
      statusColor = const Color(0xFF2563EB);
      statusBg = const Color(0xFFDBEAFE);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bill.isDueToday ? const Color(0xFFFCA5A5) : AppColors.border,
          width: bill.isDueToday ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              bill.isPaid
                  ? Icons.check_circle_rounded
                  : (bill.isDueToday || bill.isDueTomorrow
                      ? Icons.alarm_rounded
                      : Icons.receipt_rounded),
              color: statusColor,
              size: 20,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bill.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          decoration: bill.isPaid ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${bill.category} • ${formatDate(bill.dueDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      formatCurrency(bill.amount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: bill.isPaid ? AppColors.textMuted : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(8),
          IconButton(
            icon: Icon(
              bill.isPaid ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: bill.isPaid ? const Color(0xFF16A34A) : AppColors.textSecondary,
              size: 24,
            ),
            tooltip: bill.isPaid ? strings.paid : strings.markPaid,
            onPressed: () {
              ref.read(billRemindersProvider.notifier).togglePaidStatus(bill.id);
            },
          ),
        ],
      ),
    );
  }

  void _showAddBillDialog(BuildContext context, WidgetRef ref, AppStrings strings) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 1));
    String selectedCategory = 'Tagihan';

    showDialog(
      context: rootNavigatorKey.currentContext ?? context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            strings.addBillReminder,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: strings.billTitleLabel,
                  hintText: strings.billTitleHint,
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const Gap(12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: strings.billAmountLabel,
                  hintText: '350000',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const Gap(12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDueDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDueDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${strings.billDueDateLabel}: ${formatDate(selectedDueDate)}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(strings.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final title = titleController.text.trim();
                final amount = double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                if (title.isNotEmpty && amount > 0) {
                  ref.read(billRemindersProvider.notifier).addReminder(
                        title: title,
                        amount: amount,
                        dueDate: selectedDueDate,
                        category: selectedCategory,
                      );
                  Navigator.pop(ctx);
                }
              },
              child: Text(strings.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const Gap(8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewRowItem extends StatelessWidget {
  final String title;
  final num amount;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _OverviewRowItem({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const Gap(14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        MoneyText(
          amount: amount,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _FintechGlassCardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Neon violet/fuchsia ambient radial glow in top right
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.7, -0.6),
        radius: 0.9,
        colors: [
          const Color(0xFFA855F7).withValues(alpha: 0.35),
          const Color(0xFF9333EA).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // 2. Translucent glass diagonal specular sweep
    final sweepPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.03),
          Colors.white.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.8,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, sweepPaint);

    // 3. Subtle metallic circuit / wave line
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    linePath.moveTo(0, size.height * 0.4);
    linePath.cubicTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.8,
      size.width,
      size.height * 0.5,
    );
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
