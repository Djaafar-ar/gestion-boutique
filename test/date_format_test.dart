import 'package:billing_app/core/utils/date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the week starts on Saturday', () {
    // Tuesday 6 October 2026 -> Saturday 3 October.
    expect(startOfWeek(DateTime(2026, 10, 6, 15, 30)), DateTime(2026, 10, 3));
    // A Saturday is its own week start.
    expect(startOfWeek(DateTime(2026, 10, 3, 8)), DateTime(2026, 10, 3));
    // Friday 9 October still belongs to the week of the 3rd.
    expect(startOfWeek(DateTime(2026, 10, 9, 23)), DateTime(2026, 10, 3));
    // Across a month change: Thursday 1 October -> Saturday 26 September.
    expect(startOfWeek(DateTime(2026, 10, 1)), DateTime(2026, 9, 26));
  });

  test('month and day starts', () {
    expect(startOfMonth(DateTime(2026, 10, 6, 15)), DateTime(2026, 10));
    expect(startOfDay(DateTime(2026, 10, 6, 15, 30)), DateTime(2026, 10, 6));
  });

  test('dates always use Latin digits', () {
    expect(formatDateTime(DateTime(2026, 10, 6, 9, 5)), '06/10/2026 09:05');
  });
}
