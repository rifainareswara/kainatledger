import 'package:intl/intl.dart';

final _idrFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

final _idrFormatDecimals = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 2,
);

String formatCurrency(num amount, {bool showDecimals = false}) {
  return showDecimals
      ? _idrFormatDecimals.format(amount)
      : _idrFormat.format(amount);
}

String formatCurrencyCompact(num amount) {
  if (amount >= 1000000000) {
    return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
  } else if (amount >= 1000000) {
    return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
  } else if (amount >= 1000) {
    return 'Rp ${(amount / 1000).toStringAsFixed(0)}Rb';
  }
  return formatCurrency(amount);
}

double parseCurrency(String value) {
  String clean = value.replaceAll(RegExp(r'[^\d,\.]'), '');
  if (clean.contains(',') && clean.contains('.')) {
    clean = clean.replaceAll('.', '').replaceAll(',', '.');
  } else if (clean.contains('.')) {
    final parts = clean.split('.');
    if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
      clean = clean.replaceAll('.', '');
    }
  } else if (clean.contains(',')) {
    clean = clean.replaceAll(',', '.');
  }
  return double.tryParse(clean) ?? 0;
}
