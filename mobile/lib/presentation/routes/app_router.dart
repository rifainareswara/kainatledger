import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../providers/locale_provider.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/budget/budget_page.dart';
import '../pages/categories/categories_page.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/goals/goals_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/reports/reports_page.dart';
import '../pages/transactions/transaction_form_page.dart';
import '../pages/transactions/transactions_page.dart';
import '../pages/wallets/transfer_form_page.dart';
import '../pages/wallets/wallet_form_page.dart';
import '../pages/wallets/wallets_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_plus_button.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        return isLoggingIn ? null : '/login';
      }

      if (!isAuth && !isLoggingIn) {
        return '/login';
      }

      if (isAuth && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) {
              final walletId = state.uri.queryParameters['walletId'];
              return TransactionsPage(initialWalletId: walletId);
            },
          ),
          GoRoute(
            path: '/transactions/new',
            builder: (context, state) {
              final type = state.uri.queryParameters['type'];
              return TransactionFormPage(initialType: type);
            },
          ),
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetPage(),
          ),
          GoRoute(
            path: '/goals',
            builder: (context, state) => const GoalsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: '/wallets',
            builder: (context, state) => const WalletsPage(),
          ),
          GoRoute(
            path: '/wallets/new',
            builder: (context, state) => const WalletFormPage(),
          ),
          GoRoute(
            path: '/wallets/transfer',
            builder: (context, state) => const TransferFormPage(),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoriesPage(),
          ),
        ],
      ),
    ],
  );
});

class _ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const _ScaffoldWithNavBar({required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/budget')) return 2;
    if (location.startsWith('/goals')) return 3;
    if (location.startsWith('/profile')) return 4;
    if (location.startsWith('/reports')) return 5;
    if (location.startsWith('/wallets')) return 6;
    if (location.startsWith('/categories')) return 7;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        context.go('/budget');
        break;
      case 3:
        context.go('/goals');
        break;
      case 4:
        context.go('/profile');
        break;
      case 5:
        context.go('/reports');
        break;
      case 6:
        context.go('/wallets');
        break;
      case 7:
        context.go('/categories');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 700 && width < 1100;
    final selectedIndex = _calculateSelectedIndex(context);

    if (isTablet || isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              extended: isDesktop,
              minExtendedWidth: 210,
              backgroundColor: Colors.white,
              indicatorColor: AppColors.primary.withValues(alpha: 0.12),
              indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              selectedIconTheme: const IconThemeData(color: AppColors.primary),
              unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        size: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    if (isDesktop) ...[
                      const SizedBox(width: 10),
                      const Text(
                        'KainatLedger',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout, size: 20, color: AppColors.textSecondary),
                      tooltip: strings.logoutButton,
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(strings.logoutConfirmTitle),
                            content: Text(strings.logoutConfirmMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(strings.cancel),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(strings.logoutConfirmTitle),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) context.go('/login');
                        }
                      },
                    ),
                  ),
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: Text(strings.navHome),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.receipt_long_outlined),
                  selectedIcon: const Icon(Icons.receipt_long),
                  label: Text(strings.navTransactions),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: const Icon(Icons.account_balance_wallet),
                  label: Text(strings.navBudgets),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.pie_chart_outline),
                  selectedIcon: const Icon(Icons.pie_chart),
                  label: Text(strings.navGoals),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: Text(strings.navProfile),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.bar_chart_outlined),
                  selectedIcon: const Icon(Icons.bar_chart),
                  label: Text(strings.navReports),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: const Icon(Icons.account_balance_wallet),
                  label: Text(strings.navWallets),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.category_outlined),
                  selectedIcon: const Icon(Icons.category),
                  label: Text(strings.navCategories),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
            Expanded(child: child),
          ],
        ),
      );
    }

    final bottomNavIndex = selectedIndex > 4 ? 0 : selectedIndex;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Row(
                children: [
                  Expanded(
                    child: _GlassmorphicBottomNavBar(
                      currentIndex: bottomNavIndex,
                      onTap: (index) => _onItemTapped(index, context),
                      strings: strings,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GlassPlusButton(
                    onTap: () => _showQuickActionModal(context, strings),
                    tooltip: strings.isId ? 'Aksi Tambah' : 'Add Actions',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassmorphicBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppStrings strings;

  const _GlassmorphicBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _GlassNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: strings.navHome,
      ),
      _GlassNavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: strings.navTransactions,
      ),
      _GlassNavItem(
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
        label: strings.navBudgets,
      ),
      _GlassNavItem(
        icon: Icons.pie_chart_outline_rounded,
        activeIcon: Icons.pie_chart_rounded,
        label: strings.navGoals,
      ),
      _GlassNavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: strings.navProfile,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.09),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.85),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.65),
                  Colors.white.withValues(alpha: 0.40),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.88),
                width: 1.4,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = currentIndex == index;

                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      splashColor: AppColors.primary.withValues(alpha: 0.10),
                      highlightColor: Colors.transparent,
                      onTap: () => onTap(index),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutCubic,
                                padding: isSelected
                                    ? const EdgeInsets.symmetric(horizontal: 14, vertical: 4)
                                    : const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.14)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.20),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: AnimatedScale(
                                  scale: isSelected ? 1.10 : 1.0,
                                  duration: const Duration(milliseconds: 240),
                                  curve: Curves.easeOutBack,
                                  child: Icon(
                                    isSelected ? item.activeIcon : item.icon,
                                    size: 22,
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFF64748B),
                                  letterSpacing: isSelected ? -0.1 : -0.2,
                                ),
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutBack,
                                width: isSelected ? 16 : 0,
                                height: isSelected ? 2.5 : 0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD946EF),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

void _showQuickActionModal(BuildContext context, AppStrings strings) {
  showModalBottomSheet(
    context: rootNavigatorKey.currentContext ?? context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.isId ? 'Aksi Cepat Finansial' : 'Quick Actions',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _QuickActionTile(
                    icon: Icons.arrow_upward_rounded,
                    color: AppColors.expense,
                    bgColor: AppColors.expenseLight,
                    title: strings.isId ? 'Catat Pengeluaran' : 'Record Expense',
                    subtitle: strings.isId ? 'Belanja harian, tagihan, makanan' : 'Shopping, bills, dining',
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/transactions/new?type=expense');
                    },
                  ),
                  const SizedBox(height: 8),
                  _QuickActionTile(
                    icon: Icons.arrow_downward_rounded,
                    color: AppColors.income,
                    bgColor: AppColors.incomeLight,
                    title: strings.isId ? 'Catat Pemasukan' : 'Record Income',
                    subtitle: strings.isId ? 'Gaji, bonus, hasil investasi' : 'Salary, bonus, returns',
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/transactions/new?type=income');
                    },
                  ),
                  const SizedBox(height: 8),
                  _QuickActionTile(
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFE0F2FE),
                    title: strings.isId ? 'Tambah Dompet Baru' : 'Add New Wallet',
                    subtitle: strings.isId ? 'Rekening bank, tunai, e-wallet' : 'Bank account, cash, e-wallet',
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/wallets/new');
                    },
                  ),
                  const SizedBox(height: 8),
                  _QuickActionTile(
                    icon: Icons.category_rounded,
                    color: const Color(0xFF0D9488),
                    bgColor: const Color(0xFFCCFBF1),
                    title: strings.isId ? 'Kelola Kategori' : 'Manage Categories',
                    subtitle: strings.isId ? 'Tambah dan atur pos keuangan' : 'Add and manage categories',
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/categories');
                    },
                  ),
                  const SizedBox(height: 8),
                  _QuickActionTile(
                    icon: Icons.track_changes_rounded,
                    color: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF3E8FF),
                    title: strings.isId ? 'Target Tabungan Baru' : 'New Savings Goal',
                    subtitle: strings.isId ? 'Beli mobil, liburan, dana darurat' : 'New car, vacation, emergency fund',
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/goals');
                    },
                  ),
                  const SizedBox(height: 8),
                  _QuickActionTile(
                    icon: Icons.swap_horiz_rounded,
                    color: AppColors.primary,
                    bgColor: AppColors.primaryLight,
                    title: strings.isId ? 'Transfer Saldo Dompet' : 'Transfer Between Wallets',
                    subtitle: strings.isId ? 'Pindah saldo dari bank ke e-wallet' : 'Move funds between accounts',
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/wallets/transfer');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
