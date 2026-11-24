import 'package:flutter_test/flutter_test.dart';
import 'package:kainatledger/core/utils/date_formatter.dart';

void main() {
  group('Date Formatter Tests', () {
    test('formatApiDate produces yyyy-MM-dd format', () {
      final date = DateTime(2026, 11, 23);
      expect(formatApiDate(date), '2026-11-23');
    });

    test('relativeDate correctly labels today and yesterday', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      expect(relativeDate(now), 'Hari ini');
      expect(relativeDate(yesterday), 'Kemarin');
    });
  });
}
