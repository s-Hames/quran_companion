import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFriendly(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = today.difference(target).inDays;
    if (diff == 0) {
      return 'Today at ${DateFormat('h:mm a').format(date)}';
    } else if (diff == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(date)}';
    } else if (diff < 7 && diff > 0) {
      return '${DateFormat('EEEE').format(date)} at ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, y • h:mm a').format(date);
    }
  }

  static String formatDateOnly(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM y').format(date);
  }
}
