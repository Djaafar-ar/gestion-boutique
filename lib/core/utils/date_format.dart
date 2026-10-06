import 'package:intl/intl.dart';

// Dates use numbers only (06/10/2026 14:32) so they read the same in
// Arabic, French and English, always with Latin digits.

String formatDate(DateTime date) =>
    DateFormat('dd/MM/yyyy', 'en_US').format(date);

String formatTime(DateTime date) => DateFormat('HH:mm', 'en_US').format(date);

String formatDateTime(DateTime date) =>
    DateFormat('dd/MM/yyyy HH:mm', 'en_US').format(date);

/// Midnight at the start of [date]'s day.
DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// In Algeria the week starts on Saturday.
const firstDayOfWeek = DateTime.saturday;

/// Midnight on the first day of [date]'s week.
DateTime startOfWeek(DateTime date) {
  final daysBack = (date.weekday - firstDayOfWeek) % 7;
  final day = startOfDay(date);
  return DateTime(day.year, day.month, day.day - daysBack);
}

/// Midnight on the first day of [date]'s month.
DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);
