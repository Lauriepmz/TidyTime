import 'package:tidytime/utils/all_imports.dart';

class DateHelper {
  // Convert DateTime to string in a readable format (yyyy-MM-dd)
  static String dateTimeToString(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  // Convert a string (yyyy-MM-dd) from SQLite to a DateTime object
  static DateTime sqlToDateTime(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      throw Exception("Failed to parse date: $dateStr");
    }
  }

  // Convert a DateTime object to a format suitable for SQLite storage (ISO format)
  static String dateTimeToSql(DateTime date) {
    return date.toIso8601String();
  }

  static DateTime? tryParseDate(String? date) {
    if (date == null) return null;
    try {
      return DateTime.parse(date);
    } catch (_) {
      return null;
    }
  }
}
