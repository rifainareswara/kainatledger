import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/bill_reminder.dart';

const String _kBillRemindersPrefKey = 'kainat_bill_reminders_v1';

class BillReminderNotifier extends StateNotifier<List<BillReminder>> {
  final Set<String> _notifiedBillKeys = {};

  BillReminderNotifier() : super([]) {
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kBillRemindersPrefKey);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
        final loaded = decoded
            .map((item) => BillReminder.fromJson(item as Map<String, dynamic>))
            .toList();
        state = loaded;
      } else {
        // Initial realistic seed data: 1 bill due today, 1 bill due tomorrow, 1 in 3 days
        final now = DateTime.now();
        final seedBills = [
          BillReminder(
            id: 'bill-1',
            title: 'BPJS Kesehatan',
            amount: 150000,
            dueDate: DateTime(now.year, now.month, now.day, 12, 0),
            category: 'Kesehatan',
            isPaid: false,
          ),
          BillReminder(
            id: 'bill-2',
            title: 'Listrik PLN',
            amount: 350000,
            dueDate: DateTime(now.year, now.month, now.day).add(const Duration(days: 1, hours: 10)),
            category: 'Utilitas',
            isPaid: false,
          ),
          BillReminder(
            id: 'bill-3',
            title: 'WiFi IndiHome',
            amount: 280000,
            dueDate: DateTime(now.year, now.month, now.day).add(const Duration(days: 3, hours: 14)),
            category: 'Internet',
            isPaid: false,
          ),
        ];
        state = seedBills;
        await _saveReminders(seedBills);
      }

      // Automatically trigger device notification for any bills due today or tomorrow
      checkAndNotifyImpendingBills();
    } catch (_) {
      // Fallback empty or ignore
    }
  }

  Future<void> _saveReminders(List<BillReminder> reminders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(reminders.map((r) => r.toJson()).toList());
      await prefs.setString(_kBillRemindersPrefKey, encoded);
    } catch (_) {}
  }

  Future<void> checkAndNotifyImpendingBills() async {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';

    for (final bill in state) {
      if (bill.isPaid) continue;

      if (bill.isDueToday || bill.isDueTomorrow) {
        final uniqueKey = '$todayKey-${bill.id}-${bill.isDueToday ? "today" : "tomorrow"}';
        if (!_notifiedBillKeys.contains(uniqueKey)) {
          _notifiedBillKeys.add(uniqueKey);

          final whenText = bill.isDueToday ? 'Jatuh tempo HARI INI!' : 'Jatuh tempo BESOK (H-1)!';
          final title = '⏰ Pengingat Tagihan: ${bill.title}';
          final body = '$whenText Segera bayar ${formatCurrency(bill.amount)}.';

          NotificationService.showNotification(title, body);
        }
      }
    }
  }

  Future<void> addReminder({
    required String title,
    required double amount,
    required DateTime dueDate,
    String category = 'Tagihan',
    String? notes,
  }) async {
    final newBill = BillReminder(
      id: 'bill-${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      amount: amount,
      dueDate: dueDate,
      category: category,
      notes: notes,
      isPaid: false,
    );

    state = [newBill, ...state];
    await _saveReminders(state);
    checkAndNotifyImpendingBills();
  }

  Future<void> markAsPaid(String id) async {
    state = [
      for (final bill in state)
        if (bill.id == id)
          bill.copyWith(isPaid: true, paidAt: DateTime.now())
        else
          bill,
    ];
    await _saveReminders(state);
  }

  Future<void> togglePaidStatus(String id) async {
    state = [
      for (final bill in state)
        if (bill.id == id)
          bill.copyWith(isPaid: !bill.isPaid, paidAt: !bill.isPaid ? DateTime.now() : null)
        else
          bill,
    ];
    await _saveReminders(state);
  }

  Future<void> deleteReminder(String id) async {
    state = state.where((b) => b.id != id).toList();
    await _saveReminders(state);
  }
}

final billRemindersProvider =
    StateNotifierProvider<BillReminderNotifier, List<BillReminder>>((ref) {
  return BillReminderNotifier();
});

/// Urgent bills due today or tomorrow that are not yet paid
final urgentBillRemindersProvider = Provider<List<BillReminder>>((ref) {
  final allBills = ref.watch(billRemindersProvider);
  return allBills.where((b) => !b.isPaid && (b.isDueToday || b.isDueTomorrow || b.isOverdue)).toList();
});

/// Count of bills needing attention
final unpaidBillCountProvider = Provider<int>((ref) {
  final allBills = ref.watch(billRemindersProvider);
  return allBills.where((b) => !b.isPaid && (b.isDueToday || b.isDueTomorrow || b.isOverdue)).length;
});
