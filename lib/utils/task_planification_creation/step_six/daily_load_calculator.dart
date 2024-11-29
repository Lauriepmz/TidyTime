class DailyLoadManager {
  /// Calculates the initial daily load for a list of tasks over a range of flexible dates.
  static Map<DateTime, int> calculateDailyLoad(
      List<DateTime> flexibleDates, List<Map<String, dynamic>> tasksInGroup) {
    Map<DateTime, int> dailyLoad = {for (var date in flexibleDates) date: 0};

    for (var task in tasksInGroup) {
      int taskValue = (task["value"] ?? 1).round();

      for (var dueDate in task["dueDates"] ?? []) {
        if (dailyLoad.containsKey(dueDate)) {
          dailyLoad[dueDate] = dailyLoad[dueDate]! + taskValue;
        }
      }
    }
    return dailyLoad;
  }

  /// Recalculates the daily load after assigning tasks, considering penalties for proximity.
  static Map<DateTime, int> recalculateDailyLoad(
      List<DateTime> yearlyDates, List<Map<String, dynamic>> tasksInGroup) {
    Map<DateTime, int> recalculatedDailyLoad = {for (var date in yearlyDates) date: 0};

    for (var task in tasksInGroup) {
      int taskValue = (task["value"] ?? 1).round();

      for (var dueDate in task["dueDates"] ?? []) {
        if (recalculatedDailyLoad.containsKey(dueDate)) {
          // Update the main date with the full task value
          recalculatedDailyLoad[dueDate] = recalculatedDailyLoad[dueDate]! + taskValue;

          // Apply smaller penalties to surrounding dates (±2 days)
          for (int offset = -2; offset <= 2; offset++) {
            if (offset == 0) continue; // Skip the main date itself
            DateTime surroundingDate = dueDate.add(Duration(days: offset));
            if (recalculatedDailyLoad.containsKey(surroundingDate)) {
              recalculatedDailyLoad[surroundingDate] =
                  recalculatedDailyLoad[surroundingDate]! + (taskValue ~/ 2);
            }
          }
        }
      }
    }
    return recalculatedDailyLoad;
  }
}
