import 'package:tidytime/utils/all_imports.dart';

Future<void> adjustForTimeProportion(
    Map<String, Map<String, dynamic>> groupTimeProportions,
    List<Map<String, dynamic>> taskWeights,
    {double tolerance = 0.10}) async {

  // Calculate total weight for all tasks
  int totalTaskValue = taskWeights.fold(0, (sum, task) => sum + (task["value"] as int));

  // Calculate ideal values with tolerance ranges for each group based on time proportion
  Map<String, Map<String, int>> idealGroupRanges = {
    for (var day in groupTimeProportions.keys)
      day: {
        "idealMin": (groupTimeProportions[day]!["timeProportion"] * totalTaskValue * (1 - tolerance)).toInt(),
        "idealMax": (groupTimeProportions[day]!["timeProportion"] * totalTaskValue * (1 + tolerance)).toInt()
      }
  };

  // Adjust each group's total value to stay within the tolerance range of ideal proportions
  for (var day in groupTimeProportions.keys) {
    // Skip adjustment if timeProportion is 0
    if (groupTimeProportions[day]?["timeProportion"] == 0.0) {
      groupTimeProportions[day]!["totalValue"] = 0;
      groupTimeProportions[day]!["tasks"] = [];
      print("Day $day has a time proportion of 0, setting totalValue and tasks to 0.");
      continue;
    }

    int currentTotalValue = groupTimeProportions[day]!["totalValue"] as int;
    int idealMin = idealGroupRanges[day]!["idealMin"]!;
    int idealMax = idealGroupRanges[day]!["idealMax"]!;

    // If within tolerance range, skip adjustment
    if (currentTotalValue >= idealMin && currentTotalValue <= idealMax) {
      continue;
    }

    // Adjust if outside tolerance range
    if (currentTotalValue > idealMax) {
      redistributeExcessTasks(groupTimeProportions[day]!, groupTimeProportions, idealMax);
    } else if (currentTotalValue < idealMin) {
      redistributeDeficitTasks(groupTimeProportions[day]!, groupTimeProportions, idealMin, taskWeights);
    }

    // Update the group's total task value after adjustment
    groupTimeProportions[day]!["totalValue"] = calculateTotalValue(groupTimeProportions[day]!["tasks"]);
  }
}

void redistributeExcessTasks(
    Map<String, dynamic> group,
    Map<String, Map<String, dynamic>> groupTimeProportions,
    int idealValue) {
  List<Map<String, dynamic>> tasks = List<Map<String, dynamic>>.from(group["tasks"]);
  int currentValue = calculateTotalValue(tasks);

  // Remove tasks until the current value matches the ideal value
  while (currentValue > idealValue && tasks.isNotEmpty) {
    var removedTask = tasks.removeLast(); // Remove last task as a simple redistribution strategy
    currentValue -= removedTask["value"] as int;

    // Redistribute removed task to another group
    String targetDay = findUnderloadedGroup(groupTimeProportions, idealValue);
    if (groupTimeProportions[targetDay]?["timeProportion"] == 0.0) {
      continue; // Skip groups with zero time proportion
    }

    groupTimeProportions[targetDay]!["tasks"].add(removedTask);
    groupTimeProportions[targetDay]!["totalValue"] += removedTask["value"] as int;
  }

  group["tasks"] = tasks; // Update the group with redistributed tasks
}

void redistributeDeficitTasks(
    Map<String, dynamic> group,
    Map<String, Map<String, dynamic>> groupTimeProportions,
    int idealMin,
    List<Map<String, dynamic>> taskWeights) {

  List<Map<String, dynamic>> tasks = List<Map<String, dynamic>>.from(group["tasks"]);
  int currentValue = calculateTotalValue(tasks);

  // Add tasks until the current value meets the minimum threshold
  for (var task in taskWeights) {
    if (currentValue >= idealMin) break; // Stop if within range

    String targetDay = findUnderloadedGroup(groupTimeProportions, idealMin);
    if (groupTimeProportions[targetDay]?["timeProportion"] == 0.0) {
      continue; // Skip groups with zero time proportion
    }

    groupTimeProportions[targetDay]!["tasks"].add(task);
    groupTimeProportions[targetDay]!["totalValue"] += task["value"] as int;
    currentValue += task["value"] as int;
  }
}

int calculateTotalValue(List<Map<String, dynamic>> tasks) {
  return tasks.fold(0, (sum, task) => sum + (task["value"] as int));
}

String findUnderloadedGroup(Map<String, Map<String, dynamic>> groupTimeProportions, int idealValue) {
  // Find a group with the lowest total value compared to its ideal
  return groupTimeProportions.entries
      .where((entry) => (entry.value["totalValue"] ?? 0) < idealValue)
      .reduce((a, b) => (a.value["totalValue"] ?? 0) < (b.value["totalValue"] ?? 0) ? a : b)
      .key;
}

