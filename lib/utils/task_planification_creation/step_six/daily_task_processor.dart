import 'package:tidytime/utils/all_imports.dart';

class DailyTaskProcessor {
   static Future<void> processDailyTasks(
      List<Map<String, dynamic>> dailyRepeatTasks,
      DateTime startDate,
      String groupDay,
      Map<String, DateTime> groupStartDates,
      ) async {
    // Generate all yearly dates for the group
    List<DateTime> allYearDates = _generateYearlyDates(startDate, includeAllDays: true);

    // Initialize daily load tracking
    Map<DateTime, int> dailyLoad = {for (var date in allYearDates) date: 0};

    for (var task in dailyRepeatTasks) {
      // Assign start dates based on the group's weekday
      DateTime targetDayStart = groupStartDates[groupDay]!;
      task["startDate"] = _getNextOccurrenceOfDay(groupDay, targetDayStart);

      // Generate due dates for daily tasks
      task["dueDates"] = TaskDueDateGenerator.generateDueDates(task, task["startDate"]);

      // Update daily load for each due date
      int taskValue = (task["value"] ?? 1).round();
      for (var dueDate in task["dueDates"] ?? []) {
        if (dailyLoad.containsKey(dueDate)) {
          dailyLoad[dueDate] = dailyLoad[dueDate]! + taskValue;
        }
      }
    }
  }

    static DateTime _getNextOccurrenceOfDay(String day, DateTime startDate) {
    Map<String, int> daysOfWeek = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    int targetWeekday = daysOfWeek[day]!;
    while (startDate.weekday != targetWeekday) {
      startDate = startDate.add(Duration(days: 1));
    }
    return startDate;
  }

  static List<DateTime> _generateYearlyDates(DateTime startDate, {bool includeAllDays = false}) {
    List<DateTime> yearlyDates = [];
    DateTime currentDate = startDate;
    DateTime oneYearLater = startDate.add(Duration(days: 364));

    while (currentDate.isBefore(oneYearLater)) {
      yearlyDates.add(currentDate);
      currentDate = includeAllDays
          ? currentDate.add(Duration(days: 1))
          : currentDate.add(Duration(days: 7));
    }

    return yearlyDates;
  }
}
