import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  final String? initialType;
  const TransactionFormPage({super.key, this.initialType});

  @override
  ConsumerState<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _paymentMethodController = TextEditingController();

  String? _selectedWalletId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType == 'income' ? 'income' : 'expense';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih dompet')),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    final success = await ref.read(transactionActionsProvider.notifier).createTransaction(
          walletId: _selectedWalletId!,
          categoryId: _selectedCategoryId!,
          amount: amount,
          date: _selectedDate,
          note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
          paymentMethod: _paymentMethodController.text.trim().isNotEmpty
              ? _paymentMethodController.text.trim()
              : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dicatat')),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/transactions');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsProvider);
    final categoriesAsync = ref.watch(categoriesProvider(_type));
    final actionState = ref.watch(transactionActionsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          _type == 'expense' ? 'Catat Pengeluaran' : 'Catat Pemasukan',
          style: const TextStyle(
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
              context.canPop() ? context.pop() : context.go('/transactions'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeSelectionButton(
                        label: 'Pengeluaran',
                        isSelected: _type == 'expense',
                        selectedColor: AppColors.expense,
                        onTap: () {
                          setState(() {
                            _type = 'expense';
                            _selectedCategoryId = null;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _TypeSelectionButton(
                        label: 'Pemasukan',
                        isSelected: _type == 'income',
                        selectedColor: AppColors.income,
                        onTap: () {
                          setState(() {
                            _type = 'income';
                            _selectedCategoryId = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),

              // Amount Field
              CustomTextField(
                label: 'Nominal (Rp)',
                hint: '0',
                controller: _amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nominal wajib diisi';
                  }
                  final parsed = double.tryParse(val.replaceAll(RegExp(r'[^\d.]'), ''));
                  if (parsed == null || parsed <= 0) {
                    return 'Masukkan nominal angka yang valid';
                  }
                  return null;
                },
              ),
              const Gap(16),

              // Wallet Selector
              const Text(
                'Pilih Dompet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Gap(6),
              walletsAsync.when(
                data: (wallets) {
                  if (wallets.isEmpty) {
                    return TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Buat dompet terlebih dahulu'),
                      onPressed: () => context.go('/wallets/new'),
                    );
                  }
                  if (_selectedWalletId == null && wallets.isNotEmpty) {
                    _selectedWalletId = wallets.first.id;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedWalletId,
                        isExpanded: true,
                        items: wallets.map((w) {
                          return DropdownMenuItem<String>(
                            value: w.id,
                            child: Text('${w.name} (Saldo: Rp ${w.balance.toInt()})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedWalletId = val;
                          });
                        },
                      ),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Gagal memuat dompet'),
              ),
              const Gap(16),

              // Category Selector
              const Text(
                'Pilih Kategori',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Gap(6),
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Buat kategori terlebih dahulu'),
                      onPressed: () => context.go('/categories'),
                    );
                  }
                  if (_selectedCategoryId == null && categories.isNotEmpty) {
                    _selectedCategoryId = categories.first.id;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategoryId,
                        isExpanded: true,
                        items: categories.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCategoryId = val;
                          });
                        },
                      ),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Gagal memuat kategori'),
              ),
              const Gap(16),

              // Date Picker
              const Text(
                'Tanggal',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Gap(6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDate(_selectedDate),
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const Gap(16),

              // Note Field
              CustomTextField(
                label: 'Catatan (Opsional)',
                hint: 'Keterangan transaksi',
                controller: _noteController,
              ),
              const Gap(16),

              // Payment Method
              CustomTextField(
                label: 'Metode Pembayaran (Opsional)',
                hint: 'Contoh: Tunai, Transfer, QRIS',
                controller: _paymentMethodController,
              ),
              const Gap(28),

              // Save Button
              CustomButton(
                label: 'Simpan Transaksi',
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

class _TypeSelectionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TypeSelectionButton({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
