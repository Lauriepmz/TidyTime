class TaskDueDateGenerator {
  /// Generates due dates for a task starting from a given date.
  /// Calculates dates using the repeat unit and repeat value.
  static List<DateTime> generateDueDates(Map<String, dynamic> task, DateTime startDate) {
    String repeatUnit = task["repeatUnit"];
    int repeatValue = task["repeatValue"] ?? 1;
    List<DateTime> dueDates = [];

    int repeatDays = convertRepeatUnitToDays(repeatUnit, repeatValue);
    DateTime currentDate = startDate;

    // Generate due dates for approximately one year (12 cycles of the repeat duration)
    while (currentDate.isBefore(startDate.add(Duration(days: repeatDays * 12)))) {
      dueDates.add(currentDate);
      currentDate = currentDate.add(Duration(days: repeatDays));
    }

    return dueDates;
  }

  /// Generates due dates for a task based on a specific start date.
  /// Ensures dates align with a flexible date range.
  static List<DateTime> generateDueDatesForStartDate(
      DateTime startDate, int repeatDays, List<DateTime> flexibleDates) {
    List<DateTime> dueDates = [];
    DateTime currentDate = startDate;

    // Ensure that only flexible dates are included
    while (currentDate.isBefore(flexibleDates.last)) {
      if (flexibleDates.contains(currentDate)) {
        dueDates.add(currentDate);
      }
      currentDate = currentDate.add(Duration(days: repeatDays));
    }

    return dueDates;
  }

  /// Converts repeat units (days, weeks, months) into equivalent days for calculations.
  static int convertRepeatUnitToDays(String repeatUnit, int repeatValue) {
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
