import 'package:tidytime/utils/all_imports.dart';

class ProximityPenaltyManager {
  /// Calculates a score for potential start dates based on daily load impact, delay penalty, and proximity penalty.
  static Map<DateTime, double> calculateDateScores(
      List<DateTime> flexibleDates,
      Map<DateTime, int> dailyLoad,
      Map<String, dynamic> task,
      int repeatDays,
      List<Map<String, dynamic>> tasksInGroup) {
    int taskValue = (task["value"] ?? 1).round();

    Map<DateTime, double> dateScores = {};

    for (DateTime potentialStartDate in flexibleDates) {
      // Generate projected due dates for the potential start date
      List<DateTime> projectedDueDates =
      TaskDueDateGenerator.generateDueDatesForStartDate(potentialStartDate, repeatDays, flexibleDates);

      // Calculate daily load impact
      int dailyLoadImpact = _calculateDailyLoadImpact(projectedDueDates, dailyLoad, taskValue);

      // Calculate delay penalty
      int delayPenalty = potentialStartDate.difference(flexibleDates.first).inDays;

      // Calculate proximity penalty
      int proximityPenalty = _calculateProximityPenalty(projectedDueDates, dailyLoad, taskValue);

      // Final score with weight adjustments
      double score = (dailyLoadImpact * 0.6) + (delayPenalty * 0.3) + (proximityPenalty * 0.1);
      dateScores[potentialStartDate] = score;

    }

    return dateScores;
  }

  /// Finds the optimal start date based on calculated date scores.
  static DateTime findOptimalStartDate(Map<DateTime, double> dateScores) {
    return dateScores.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  /// Calculates the daily load impact for a set of projected due dates.
  static int _calculateDailyLoadImpact(
      List<DateTime> projectedDueDates, Map<DateTime, int> dailyLoad, int taskValue) {
    int impact = 0;
    for (DateTime dueDate in projectedDueDates) {
      if (dailyLoad.containsKey(dueDate)) {
        impact += dailyLoad[dueDate]! + taskValue;
      }
    }
    return impact;
  }

  /// Calculates the proximity penalty for a set of projected due dates.
  static int _calculateProximityPenalty(
      List<DateTime> projectedDueDates, Map<DateTime, int> dailyLoad, int taskValue) {
    int penalty = 0;

    for (DateTime dueDate in projectedDueDates) {
      for (DateTime date in dailyLoad.keys) {
        if (date != dueDate && (dueDate.difference(date).inDays.abs() <= 2)) {
          penalty += taskValue;
        }
      }
    }

    return penalty;
  }
}
