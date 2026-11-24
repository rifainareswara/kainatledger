import 'package:flutter_test/flutter_test.dart';
import 'package:kainatledger/domain/models/bill_reminder.dart';

void main() {
  group('BillReminder Domain Model Tests', () {
    test('isDueToday is true when due date is today', () {
      final now = DateTime.now();
      final bill = BillReminder(
        id: '1',
        title: 'Listrik PLN',
        amount: 350000,
        dueDate: DateTime(now.year, now.month, now.day, 14, 0),
      );

      expect(bill.isDueToday, isTrue);
      expect(bill.isDueTomorrow, isFalse);
      expect(bill.shouldNotifyDevice, isTrue);
      expect(bill.getStatusLabel(isId: true), 'Jatuh Tempo Hari Ini!');
    });

    test('isDueTomorrow is true when due date is tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final bill = BillReminder(
        id: '2',
        title: 'WiFi IndiHome',
        amount: 280000,
        dueDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
      );

      expect(bill.isDueToday, isFalse);
      expect(bill.isDueTomorrow, isTrue);
      expect(bill.shouldNotifyDevice, isTrue);
      expect(bill.getStatusLabel(isId: true), 'Jatuh Tempo Besok (H-1)');
    });

    test('paid bill returns Lunas and shouldNotifyDevice is false', () {
      final now = DateTime.now();
      final bill = BillReminder(
        id: '3',
        title: 'BPJS Kesehatan',
        amount: 150000,
        dueDate: now,
        isPaid: true,
      );

      expect(bill.shouldNotifyDevice, isFalse);
      expect(bill.getStatusLabel(isId: true), 'Lunas');
      expect(bill.getStatusLabel(isId: false), 'Paid');
    });

    test('toJson and fromJson preserves all fields', () {
      final date = DateTime(2026, 12, 1, 10, 0);
      final bill = BillReminder(
        id: 'test-1',
        title: 'Air PDAM',
        amount: 75000,
        dueDate: date,
        category: 'Utilitas',
        isPaid: false,
      );

      final json = bill.toJson();
      final restored = BillReminder.fromJson(json);

      expect(restored.id, 'test-1');
      expect(restored.title, 'Air PDAM');
      expect(restored.amount, 75000);
      expect(restored.dueDate, date);
      expect(restored.category, 'Utilitas');
      expect(restored.isPaid, isFalse);
    });
  });
}
