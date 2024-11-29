import 'package:tidytime/utils/all_imports.dart';

Future<Map<String, dynamic>> initializeGroupTimeProportions() async {
  final hiveBoxManager = HiveBoxManager.instance;

  // Fetch the timeProportionBox directly using hiveBoxManager, assuming it’s initialized
  final timeProportionBox = hiveBoxManager.getBox<TimeProportion>('tempTimeProportionBox');

  final timeProportions = timeProportionBox.values.toList();
  final List<String> dayMapping = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  Map<String, Map<String, dynamic>> groupTimeProportions = {
    for (var day in dayMapping)
      day: {
        "timeProportion": 0.0, // Placeholder to be updated
        "totalValue": 0,       // Placeholder to be calculated
        "tasks": []            // Start with an empty list of tasks
      }
  };

  // Log and apply the saved time proportions to groupTimeProportions
  print("Contents of tempTimeProportionBox:");
  for (var proportion in timeProportions) {
    print("Day: ${proportion.day}, Proportion: ${proportion.allocatedProportion}");
    if (groupTimeProportions.containsKey(proportion.day)) {
      groupTimeProportions[proportion.day]!["timeProportion"] = proportion.allocatedProportion;
    } else {
      print("Warning: ${proportion.day} not found in groupTimeProportions");
    }
  }

  // Define task values based on task type
  Map<String, int> taskValueMap = {
    "Spot Clean": 1, "Filter Replacement": 1,
    "Regular Cleaning": 2, "Organization": 2, "Pet Cleaning": 2,
    "HVAC Maintenance": 2, "Drain Unclogging": 2,
    "Deep Clean": 3, "Seasonal Cleaning": 3, "Decluttering": 3,
    "Window Cleaning": 3, "Appliance Cleaning": 3,
    "Carpet Cleaning": 3, "Polishing": 3, "Outdoor": 3
  };

  List<Map<String, dynamic>> taskWeights = [];
  final selectedTasksBox = hiveBoxManager.getBox<SelectedTask>('SelectedTasks');
  final selectedTasks = selectedTasksBox.values.toList();

  final taskFetcher = TaskDetailsFetcher();
  final databaseTasks = await taskFetcher.fetchAllTasks();

  // Populate taskWeights with tasks from both temporary and database sources
  int taskCounter = 1; // Compteur global pour les IDs

  for (var task in selectedTasks) {
    final taskValue = taskValueMap[task.taskTypeSelected] ?? 1;
    taskWeights.add({
      "id": taskCounter++, // Ajouter un ID unique
      "taskName": task.taskNameSelected,
      "room": task.taskRoomSelected,
      "type": task.taskTypeSelected,
      "repeatUnit": task.repeatUnitSelected,
      "repeatValue": task.repeatValueSelected,
      "value": taskValue
    });
  }

  for (var task in databaseTasks) {
    final taskValue = taskValueMap[task["taskType"]] ?? 1;
    taskWeights.add({
      "id": taskCounter++, // Ajouter un ID unique
      "taskName": task["taskName"],
      "room": task["room"],
      "type": task["taskType"],
      "repeatUnit": task["repeatUnit"],
      "repeatValue": task["repeatValue"],
      "value": taskValue
    });
  }

  // Calculate total task value across all tasks
  int totalTaskValue = taskWeights.fold(0, (sum, task) => sum + (task["value"] as int));

  // Assign ideal total values to each group based on timeProportion
  for (var day in groupTimeProportions.keys) {
    double proportion = groupTimeProportions[day]!["timeProportion"];
    groupTimeProportions[day]!["totalValue"] = (proportion * totalTaskValue).toInt();
  }

  // Log final group proportions without assigning tasks
  print("Final groupTimeProportions after calculating target values: $groupTimeProportions");

  return {
    "groupTimeProportions": groupTimeProportions,
    "taskWeights": taskWeights
  };
}
