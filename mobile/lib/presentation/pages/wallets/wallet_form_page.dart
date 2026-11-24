import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class WalletFormPage extends ConsumerStatefulWidget {
  const WalletFormPage({super.key});

  @override
  ConsumerState<WalletFormPage> createState() => _WalletFormPageState();
}

class _WalletFormPageState extends ConsumerState<WalletFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  String _selectedType = 'bank';
  String _selectedColor = '#2563EB';

  final List<({String key, String label, IconData icon})> _walletTypes = [
    (key: 'bank', label: 'Bank', icon: Icons.account_balance),
    (key: 'cash', label: 'Tunai', icon: Icons.money),
    (key: 'e-wallet', label: 'E-Wallet', icon: Icons.phone_android),
    (key: 'credit_card', label: 'Kartu Kredit', icon: Icons.credit_card),
    (key: 'investment', label: 'Investasi', icon: Icons.trending_up),
  ];

  final List<String> _palette = [
    '#2563EB', // Blue
    '#16A34A', // Green
    '#D97706', // Amber
    '#7C3AED', // Purple
    '#0D9488', // Teal
    '#DC2626', // Red
    '#475569', // Slate
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final initialBalance =
        double.tryParse(_balanceController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;

    final success = await ref.read(walletActionsProvider.notifier).createWallet(
          name: _nameController.text.trim(),
          type: _selectedType,
          initialBalance: initialBalance,
          color: _selectedColor,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dompet berhasil dibuat')),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/wallets');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(walletActionsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Tambah Dompet Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/wallets'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Nama Dompet',
                hint: 'Contoh: BCA Utama, Gopay, Dompet Fisik',
                controller: _nameController,
                autofocus: true,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama dompet wajib diisi';
                  }
                  return null;
                },
              ),
              const Gap(16),

              const Text(
                'Jenis Dompet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Gap(8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _walletTypes.map((type) {
                  final isSelected = _selectedType == type.key;
                  return ChoiceChip(
                    avatar: Icon(
                      type.icon,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    label: Text(type.label),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedType = type.key);
                    },
                  );
                }).toList(),
              ),
              const Gap(16),

              CustomTextField(
                label: 'Saldo Awal (Rp)',
                hint: '0',
                controller: _balanceController,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Saldo awal wajib diisi';
                  }
                  final parsed = double.tryParse(val.replaceAll(RegExp(r'[^\d.]'), ''));
                  if (parsed == null || parsed < 0) {
                    return 'Nominal tidak valid';
                  }
                  return null;
                },
              ),
              const Gap(16),

              const Text(
                'Warna Aksen Dompet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Gap(8),
              Row(
                children: _palette.map((hex) {
                  final isSelected = _selectedColor == hex;
                  final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));

                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedColor = hex),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 20, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Gap(32),

              CustomButton(
                label: 'Simpan Dompet',
                isLoading: actionState.isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
