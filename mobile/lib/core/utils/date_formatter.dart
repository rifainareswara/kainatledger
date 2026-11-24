import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  try {
    return DateFormat('d MMM yyyy', 'id').format(date);
  } catch (_) {
    return DateFormat('d MMM yyyy').format(date);
  }
}

String formatDateShort(DateTime date) {
  try {
    return DateFormat('d MMM', 'id').format(date);
  } catch (_) {
    return DateFormat('d MMM').format(date);
  }
}

String formatMonthYear(DateTime date) {
  try {
    return DateFormat('MMMM yyyy', 'id').format(date);
  } catch (_) {
    return DateFormat('MMMM yyyy').format(date);
  }
}

String formatApiDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('HH:mm').format(date);
}

String formatDateFromString(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return formatDate(dt.toLocal());
}

DateTime? parseDateString(String value) => DateTime.tryParse(value);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isToday(DateTime date) => isSameDay(date, DateTime.now());
bool isYesterday(DateTime date) =>
    isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));

String relativeDate(DateTime date) {
  if (isToday(date)) return 'Hari ini';
  if (isYesterday(date)) return 'Kemarin';
  return formatDate(date);
}
