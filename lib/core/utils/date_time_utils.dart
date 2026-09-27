import 'package:intl/intl.dart';

/// Date/time helpers for medicine scheduling and display.
abstract final class DateTimeUtils {
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('d MMM yyyy, hh:mm a');

  static String formatTime(DateTime dt) => _timeFormat.format(dt);
  static String formatDate(DateTime dt) => _dateFormat.format(dt);
  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);

  static DateTime todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final h = int.parse(parts[0]);
    final m = parts.length > 1 ? int.parse(parts[1]) : 0;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  static String timeToString(DateTime dt) => _timeFormat.format(dt);

  static bool isWithinGracePeriod(DateTime scheduled, DateTime now, {int minutes = 120}) {
    final diff = now.difference(scheduled).inMinutes;
    return diff >= 0 && diff <= minutes;
  }

  static bool isPastGracePeriod(DateTime scheduled, DateTime now, {int minutes = 120}) {
    return now.difference(scheduled).inMinutes > minutes;
  }
}
