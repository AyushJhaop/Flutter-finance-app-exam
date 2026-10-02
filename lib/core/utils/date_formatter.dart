import 'package:intl/intl.dart';

/// Centralised date formatting for FinTrack.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _shortDate = DateFormat('d MMM');
  static final DateFormat _longDate = DateFormat('d MMM yyyy');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _month = DateFormat('MMM');
  static final DateFormat _dayDate = DateFormat('EEEE, d MMM yyyy');
  static final DateFormat _time = DateFormat('h:mm a');

  /// 30 Sep
  static String shortDate(DateTime date) => _shortDate.format(date);
  static String formatDate(DateTime date) => _shortDate.format(date);

  /// 30 Sep 2026
  static String longDate(DateTime date) => _longDate.format(date);
  static String formatFullDate(DateTime date) => _longDate.format(date);

  /// September 2026
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// Sep
  static String month(DateTime date) => _month.format(date);

  /// Wednesday, 30 Sep 2026
  static String dayDate(DateTime date) => _dayDate.format(date);

  /// 8:30 AM
  static String time(DateTime date) => _time.format(date);

  /// Relative label: Today, Yesterday, or shortDate
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    return shortDate(date);
  }

  /// Days until a future date (returns negative if past)
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    return date.difference(now).inDays;
  }
}
