class FlexibleDateGenerator {
   static List<DateTime> generateFlexibleDates(
      List<Map<String, dynamic>> tasksInGroup, DateTime startDate) {
    // Step 1: Calculate the full range of flexible dates for all tasks
    List<DateTime> flexibleDates = [];

    for (var task in tasksInGroup) {
      String repeatUnit = task["repeatUnit"];
      int repeatValue = task["repeatValue"] ?? 1;
      // Generate the flexible date range for this task
      List<DateTime> taskFlexibleDates =
      generateDatesWithinRange(startDate, repeatUnit, repeatValue);

      flexibleDates.addAll(taskFlexibleDates);
    }

    // Step 2: Remove duplicates and sort the dates
    flexibleDates = flexibleDates.toSet().toList();
    flexibleDates.sort();

    return flexibleDates;
  }

  static List<DateTime> generateYearlyDates(DateTime startDate, {bool includeAllDays = false}) {
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
  static List<DateTime> generateDatesWithinRange(
      DateTime startDate, String repeatUnit, int repeatValue,
      {int factor = 2}) {
    int repeatDays = _convertRepeatUnitToDays(repeatUnit, repeatValue);
    int rangeDays = repeatDays * factor;


    List<DateTime> dates = [];
    DateTime currentDate = startDate;
    DateTime endDate = startDate.add(Duration(days: rangeDays));

    while (currentDate.isBefore(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    }

    return dates;
  }

   static int _convertRepeatUnitToDays(String repeatUnit, int repeatValue) {
    switch (repeatUnit) {
      case "days":
        return repeatValue;
      case "weeks":
        return repeatValue * 7;
      case "months":
        return repeatValue * 28; // Approximating months to 4 weeks
      default:
        throw Exception("Invalid repeat unit: $repeatUnit");
    }
  }
}
