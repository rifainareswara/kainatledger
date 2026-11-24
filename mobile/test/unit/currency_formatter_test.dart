import 'package:flutter_test/flutter_test.dart';
import 'package:kainatledger/core/utils/currency_formatter.dart';

void main() {
  group('Currency Formatter Tests', () {
    test('formatCurrency formats standard Indonesian Rupiah correctly', () {
      expect(formatCurrency(1500000), 'Rp 1.500.000');
      expect(formatCurrency(0), 'Rp 0');
      expect(formatCurrency(50000), 'Rp 50.000');
    });

    test('formatCurrencyCompact formats large numbers into abbreviations', () {
      expect(formatCurrencyCompact(1500000000), 'Rp 1.5M');
      expect(formatCurrencyCompact(2500000), 'Rp 2.5Jt');
      expect(formatCurrencyCompact(50000), 'Rp 50Rb');
      expect(formatCurrencyCompact(500), 'Rp 500');
    });

    test('parseCurrency parses string to double safely', () {
      expect(parseCurrency('Rp 1.500.000'), 1500000.0);
      expect(parseCurrency('25000.50'), 25000.5);
      expect(parseCurrency('invalid'), 0.0);
    });
  });
}
