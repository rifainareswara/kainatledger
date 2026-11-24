import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class TransferFormPage extends ConsumerStatefulWidget {
  const TransferFormPage({super.key});

  @override
  ConsumerState<TransferFormPage> createState() => _TransferFormPageState();
}

class _TransferFormPageState extends ConsumerState<TransferFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _feeController = TextEditingController(text: '0');
  final _noteController = TextEditingController();

  String? _fromWalletId;
  String? _toWalletId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fromWalletId == null || _toWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet asal dan tujuan')),
      );
      return;
    }

    if (_fromWalletId == _toWalletId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dompet asal dan tujuan tidak boleh sama')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal transfer harus lebih dari 0')),
      );
      return;
    }

    final fee = double.tryParse(_feeController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;

    final success = await ref.read(walletActionsProvider.notifier).transfer(
          fromWalletId: _fromWalletId!,
          toWalletId: _toWalletId!,
          amount: amount,
          fee: fee,
          date: _selectedDate,
          note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer antar dompet berhasil')),
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
    final walletsAsync = ref.watch(walletsProvider);
    final actionState = ref.watch(walletActionsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Transfer Antar Dompet',
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
              walletsAsync.when(
                data: (wallets) {
                  if (wallets.length < 2) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Dibutuhkan minimal 2 dompet untuk melakukan transfer saldo.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                      ),
                    );
                  }

                  if (_fromWalletId == null && wallets.isNotEmpty) {
                    _fromWalletId = wallets.first.id;
                  }
                  if (_toWalletId == null && wallets.length > 1) {
                    _toWalletId = wallets[1].id;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From Wallet
                      const Text(
                        'Dompet Sumber (Pengirim)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Gap(6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _fromWalletId,
                            isExpanded: true,
                            items: wallets.map((w) {
                              return DropdownMenuItem<String>(
                                value: w.id,
                                child: Text('${w.name} (Saldo: Rp ${w.balance.toInt()})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _fromWalletId = val);
                            },
                          ),
                        ),
                      ),
                      const Gap(16),

                      // To Wallet
                      const Text(
                        'Dompet Tujuan (Penerima)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Gap(6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _toWalletId,
                            isExpanded: true,
                            items: wallets.map((w) {
                              return DropdownMenuItem<String>(
                                value: w.id,
                                child: Text('${w.name} (Saldo: Rp ${w.balance.toInt()})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _toWalletId = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Gagal memuat dompet'),
              ),
              const Gap(16),

              CustomTextField(
                label: 'Nominal Transfer (Rp)',
                hint: '0',
                controller: _amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nominal transfer wajib diisi';
                  }
                  final parsed = double.tryParse(val.replaceAll(RegExp(r'[^\d.]'), ''));
                  if (parsed == null || parsed <= 0) {
                    return 'Nominal transfer tidak valid';
                  }
                  return null;
                },
              ),
              const Gap(16),

              CustomTextField(
                label: 'Biaya Admin (Rp, Opsional)',
                hint: '0',
                controller: _feeController,
                keyboardType: TextInputType.number,
              ),
              const Gap(16),

              // Date Picker
              const Text(
                'Tanggal Transfer',
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
                    setState(() => _selectedDate = picked);
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

              CustomTextField(
                label: 'Catatan Transfer (Opsional)',
                hint: 'Keterangan transfer',
                controller: _noteController,
              ),
              const Gap(32),

              CustomButton(
                label: 'Kirim Transfer Saldo',
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
