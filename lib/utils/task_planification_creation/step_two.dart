import 'package:tidytime/utils/all_imports.dart';

Future<void> distributeTasksByRoomGroups(
    Map<String, Map<String, dynamic>> groupTimeProportions,
    List<Map<String, dynamic>> taskWeights,
    Map<int, List<String>> groupedRooms) async {

  // Debug: Initial logs for group setup and grouped rooms
  print("Initial groupTimeProportions: $groupTimeProportions");
  print("Initial groupedRooms: $groupedRooms");

  // Iterate over each task to assign them based on grouped rooms and time proportions
  for (var task in taskWeights) {
    String room = task["room"];
    int taskValue = task["value"] ?? 0;
    bool taskAssigned = false;

    int? targetGroupId;
    try {
      targetGroupId = groupedRooms.entries
          .firstWhere((entry) => entry.value.contains(room))
          .key;
    } catch (e) {
      targetGroupId = null; // Set to null if no group found
    }

    // If no group is found, mark task as overflow and continue
    if (targetGroupId == null) {
      print("Warning: No group found for room $room. Task '${task["taskName"]}' marked as overflow.");
      continue;
    }

    // Assign task based on available day group values
    for (var day in groupTimeProportions.keys) {
      double dayProportion = groupTimeProportions[day]?["timeProportion"] ?? 0.0;
      int maxAllowedValue = (dayProportion * taskWeights.fold(0, (sum, task) => sum + (task["value"] as int))).toInt();

      // Calculate the current total value for the day by summing task values
      int currentDayValue = groupTimeProportions[day]?["tasks"].fold(0, (sum, task) => sum + (task["value"] as int)) ?? 0;

      // Assign task only if it fits within the max allowed value for the day
      if (currentDayValue + taskValue <= maxAllowedValue) {
        groupTimeProportions[day]?["tasks"].add(task);
        currentDayValue += taskValue; // Update currentDayValue with the added task

        print("Assigned task '${task["taskName"]}' to $day. Updated total value for day: $currentDayValue");
        taskAssigned = true;
        break;
      }
    }

    // Mark task as overflow if it couldn't be assigned within any day
    if (!taskAssigned) {
      print("Task '${task["taskName"]}' could not be assigned within limits and is marked as overflow.");
    }
  }

  // Debug: Log final proportions and tasks for each day
  for (var day in groupTimeProportions.keys) {
    var tasks = groupTimeProportions[day]?["tasks"] ?? [];
    int totalValue = tasks.fold(0, (sum, task) => sum + (task["value"] as int));
    double proportion = groupTimeProportions[day]?["timeProportion"] ?? 0.0;

    print("Day: $day, Total Value: $totalValue, Expected Proportion: $proportion, Tasks: ${tasks.map((t) => t["taskName"]).toList()}");
  }

  print("Final groupTimeProportions after task assignment: $groupTimeProportions");
}


// Helper to handle edge cases for empty or single-room groups
void handleEmptyAndSingleRoomGroups(
    Map<String, List<Map<String, dynamic>>> assignedTasks,
    Map<String, Map<String, dynamic>> groupTimeProportions,
    List<Map<String, dynamic>> taskWeights
    ) {

  for (var day in assignedTasks.keys) {
    if (assignedTasks[day]!.isEmpty) {
      // Assign at least one task to empty groups, or handle as per user-defined rule
      if (taskWeights.isNotEmpty) {
        assignedTasks[day]!.add(taskWeights.first);
        groupTimeProportions[day]!["totalValue"] += taskWeights.first["value"] ?? 0;
        groupTimeProportions[day]!["tasks"] = assignedTasks[day];
      }
    }
  }

  // Debug: Check assigned tasks after handling empty groups
  print("Assigned tasks after handling empty/single-room groups: $assignedTasks");
}
