import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/glass_plus_button.dart';
import '../../widgets/money_text.dart';
import '../../widgets/wallet_card.dart';

class WalletsPage extends ConsumerWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);
    final summaryAsync = ref.watch(walletSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Dompet Saya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletsProvider);
          ref.invalidate(walletSummaryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Akumulasi Saldo',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const Gap(4),
                        summaryAsync.when(
                          data: (summary) => MoneyText(
                            amount: summary.totalBalance,
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          loading: () => const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (_, __) => const Text('Gagal memuat'),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/wallets/transfer'),
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Transfer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Dompet Aktif',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GlassPlusButton(
                    size: 38,
                    onTap: () => context.go('/wallets/new'),
                    tooltip: 'Tambah Dompet',
                  ),
                ],
              ),
              const Gap(12),

              walletsAsync.when(
                data: (wallets) {
                  if (wallets.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: EmptyStateWidget(
                        icon: Icons.account_balance_wallet,
                        title: 'Belum Ada Dompet',
                        message:
                            'Buat dompet pertama Anda untuk mulai mencatat keuangan (misal: Rekening Bank, Tunai, atau E-Wallet).',
                        actionLabel: 'Buat Dompet Baru',
                        onAction: () => context.go('/wallets/new'),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320,
                      mainAxisExtent: 130,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                    ),
                    itemCount: wallets.length,
                    itemBuilder: (ctx, index) {
                      final wallet = wallets[index];
                      return WalletCard(
                        wallet: wallet,
                        onTap: () => context.go('/transactions?walletId=${wallet.id}'),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (err, _) => ErrorViewWidget(
                  message: 'Gagal memuat daftar dompet',
                  onRetry: () => ref.invalidate(walletsProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
