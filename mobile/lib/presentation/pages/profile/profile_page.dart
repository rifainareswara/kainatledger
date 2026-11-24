import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/wallet_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ubah Nama Pengguna'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan nama lengkap atau panggilan baru:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const Gap(14),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Contoh: Olivia Putri, Rifai',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(userProfileProvider.notifier).updateName(newName);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Nama berhasil diubah menjadi "$newName"!')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showSecurityOptionsModal(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    UserProfile profile,
  ) {
    showModalBottomSheet(
      context: context,
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
                color: Color(0x20000000),
                blurRadius: 30,
                offset: Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
            const Gap(16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                ),
                const Gap(12),
                Text(
                  strings.accountSecurity,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Gap(18),
            // Option 1: Atur / Ganti PIN
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pin, color: AppColors.primary, size: 22),
              ),
              title: Text(
                strings.securityPin,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: Text(
                profile.hasPin
                    ? (strings.isId ? 'PIN Aktif (6-digit) • Tekan untuk ganti' : 'PIN Active (6-digit) • Tap to change')
                    : (strings.isId ? 'Belum aktif • Buat 6-digit PIN baru' : 'Not set • Create 6-digit PIN'),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: profile.hasPin ? AppColors.incomeLight : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profile.hasPin ? 'Aktif' : 'Atur',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: profile.hasPin ? AppColors.income : AppColors.primary,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showSetPinDialog(context, ref, strings, profile);
              },
            ),
            const Divider(height: 16),
            // Option 2: Ubah Kata Sandi
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_reset, color: Color(0xFFD97706), size: 22),
              ),
              title: Text(
                strings.changePassword,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: Text(
                strings.isId
                    ? 'Ganti kata sandi login Anda'
                    : 'Change your account login password',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
              onTap: () {
                Navigator.pop(ctx);
                _showChangePasswordDialog(context, strings);
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showSetPinDialog(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    UserProfile profile,
  ) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.dialpad, color: AppColors.primary, size: 22),
              const Gap(10),
              Text(
                profile.hasPin
                    ? (strings.isId ? 'Ganti PIN Keamanan' : 'Change Security PIN')
                    : (strings.isId ? 'Buat PIN Keamanan' : 'Create Security PIN'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.isId
                    ? 'Gunakan 6 digit angka rahasia untuk mengamankan data dan transaksi Anda.'
                    : 'Use a secret 6-digit numeric PIN to protect your financial data.',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const Gap(16),
              TextField(
                controller: pinController,
                autofocus: true,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: strings.enterPin,
                  hintText: '••••••',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  counterText: '',
                ),
              ),
              const Gap(12),
              TextField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: strings.confirmPin,
                  hintText: '••••••',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  counterText: '',
                ),
              ),
              if (errorMessage != null) ...[
                const Gap(8),
                Text(
                  errorMessage!,
                  style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                ),
              ],
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final pin = pinController.text.trim();
                final confirm = confirmController.text.trim();

                if (pin.length != 6 || int.tryParse(pin) == null) {
                  setModalState(() {
                    errorMessage = strings.isId
                        ? 'PIN harus terdiri dari tepat 6 angka numerik!'
                        : 'PIN must be exactly 6 numeric digits!';
                  });
                  return;
                }

                if (pin != confirm) {
                  setModalState(() {
                    errorMessage = strings.isId
                        ? 'Konfirmasi PIN tidak cocok!'
                        : 'PIN confirmation does not match!';
                  });
                  return;
                }

                ref.read(userProfileProvider.notifier).setPin(pin);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      strings.isId
                          ? 'PIN keamanan 6-digit berhasil disimpan! 🔒'
                          : '6-digit Security PIN successfully saved! 🔒',
                    ),
                  ),
                );
              },
              child: Text(strings.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AppStrings strings) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.lock_reset, color: AppColors.primary, size: 22),
              const Gap(10),
              Text(
                strings.changePassword,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: currentPassController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: strings.currentPassword,
                  hintText: '••••••••',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Gap(12),
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: strings.newPassword,
                  hintText: strings.isId ? 'Minimal 8 karakter' : 'At least 8 characters',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Gap(12),
              TextField(
                controller: confirmPassController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: strings.confirmNewPassword,
                  hintText: '••••••••',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              if (errorMessage != null) ...[
                const Gap(8),
                Text(
                  errorMessage!,
                  style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                ),
              ],
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final current = currentPassController.text;
                final newPass = newPassController.text;
                final confirm = confirmPassController.text;

                if (current.isEmpty) {
                  setModalState(() {
                    errorMessage = strings.isId
                        ? 'Masukkan kata sandi saat ini!'
                        : 'Enter your current password!';
                  });
                  return;
                }

                if (newPass.length < 8) {
                  setModalState(() {
                    errorMessage = strings.isId
                        ? 'Kata sandi baru minimal harus 8 karakter!'
                        : 'New password must be at least 8 characters!';
                  });
                  return;
                }

                if (newPass != confirm) {
                  setModalState(() {
                    errorMessage = strings.isId
                        ? 'Konfirmasi kata sandi baru tidak cocok!'
                        : 'New password confirmation does not match!';
                  });
                  return;
                }

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      strings.isId
                          ? 'Kata sandi akun Anda berhasil diperbarui! 🔑'
                          : 'Account password successfully updated! 🔑',
                    ),
                  ),
                );
              },
              child: Text(strings.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final summaryAsync = ref.watch(walletSummaryProvider);
    final strings = ref.watch(appStringsProvider);
    final currentLang = ref.watch(localeProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 800;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          strings.profileTitle,
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
          vertical: 20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                // Avatar Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            profile.name.isNotEmpty
                                ? profile.name.substring(0, 1).toUpperCase()
                                : 'O',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        profile.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Gap(10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'KainatLedger Member',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // Quick Summary
                summaryAsync.when(
                  data: (summary) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: strings.totalBalance,
                          value: formatCurrencyCompact(summary.totalBalance),
                        ),
                        Container(width: 1, height: 32, color: AppColors.border),
                        _StatItem(
                          label: strings.activeWallets,
                          value: '${summary.walletCount} ${strings.isId ? 'Dompet' : 'Wallets'}',
                        ),
                        Container(width: 1, height: 32, color: AppColors.border),
                        _StatItem(
                          label: strings.currency,
                          value: 'IDR (Rp)',
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const Gap(20),

                // Settings List
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline, color: AppColors.primary),
                          title: Text(strings.editUsername, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(profile.name),
                          trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
                          onTap: () => _showEditNameDialog(context, ref, profile.name),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        ListTile(
                          leading: const Icon(Icons.language, color: AppColors.primary),
                          title: Text(strings.languageSetting, style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => ref.read(localeProvider.notifier).setLanguage(AppLanguage.id),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: currentLang == AppLanguage.id ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '🇮🇩 ID',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: currentLang == AppLanguage.id ? Colors.white : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => ref.read(localeProvider.notifier).setLanguage(AppLanguage.en),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: currentLang == AppLanguage.en ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '🇬🇧 EN',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: currentLang == AppLanguage.en ? Colors.white : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        ListTile(
                          leading: const Icon(Icons.bar_chart_outlined, color: AppColors.primary),
                          title: Text(strings.navReports, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(strings.spendingOverview),
                          trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
                          onTap: () => context.go('/reports'),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        ListTile(
                          leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                          title: Text(strings.manageWallets, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('BCA, GoPay, Tunai, Reksadana'),
                          trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
                          onTap: () => context.go('/wallets'),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        ListTile(
                          leading: const Icon(Icons.category_outlined, color: AppColors.primary),
                          title: Text(strings.manageCategories, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('Makanan, Belanja, Transportasi, dll.'),
                          trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
                          onTap: () => context.go('/categories'),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        ListTile(
                          leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                          title: Text(strings.accountSecurity, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            profile.hasPin
                                ? (strings.isId ? 'PIN Aktif (6-digit) • Ganti kata sandi' : 'PIN Active (6-digit) • Change password')
                                : (strings.isId ? 'Atur PIN 6-digit & Ganti kata sandi' : 'Set 6-digit PIN & Change password'),
                          ),
                          trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
                          onTap: () => _showSecurityOptionsModal(context, ref, strings, profile),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(24),

                // Logout Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(
                    strings.logoutButton,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
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
                const Gap(80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
