import 'package:tidytime/utils/all_imports.dart';

Future<void> distributeByRoomPreference(
    Map<String, Map<String, dynamic>> groupTimeProportions,
    List<Map<String, dynamic>> taskWeights,
    int answer) async {
  switch (answer) {
    case 1:
    // Bundle tasks with the same name, keeping them in the same groups
      for (var group in groupTimeProportions.values) {
        if (group["tasks"] == null) continue;
        bundleTasksByName(group);
      }
      break;
    case 2:
    // Keep tasks within the same room in the same group
      for (var group in groupTimeProportions.values) {
        distributeTasksByRoom(group, sameRoom: true);
      }
      break;
    case 3:
    // Schedule weekly/daily tasks per room first, then others
      for (var group in groupTimeProportions.values) {
        prioritizeFrequentRoomTasks(group);
      }
      break;
    case 4:
    // Prioritize tasks for frequently used rooms
      for (var group in groupTimeProportions.values) {
        prioritizeHighUsageRooms(group, ["bathroom", "children's bedroom", "kitchen", "living room", "play room"]);
      }
      break;
  }

  // Apply the time proportion constraint after room-based distribution
  await adjustForTimeProportion(groupTimeProportions, taskWeights);
}

void bundleTasksByName(Map<String, dynamic> group) {
  if (group["tasks"] == null) {
    print("Group has no tasks assigned.");
    return;
  }

  List<dynamic> tasks = group["tasks"];
  List<Map<String, dynamic>> typedTasks = tasks.cast<Map<String, dynamic>>();

  Map<String, List<Map<String, dynamic>>> taskBundles = {};

  // Grouper les tâches par leur nom
  for (var task in typedTasks) {
    String taskName = task["taskName"];
    taskBundles.putIfAbsent(taskName, () => []).add(task);
  }

  // Aplatir les groupes de tâches
  group["tasks"] = taskBundles.values.expand((tasks) => tasks).toList();
}


// Helper function to keep tasks within the same room together
void distributeTasksByRoom(Map<String, dynamic> group, {bool sameRoom = true}) {
  if (group["tasks"] == null || group["tasks"].isEmpty) {
    print("No tasks to distribute by room.");
    return;
  }

  Map<String, List<Map<String, dynamic>>> roomGroups = {};

  // Grouper par pièce
  for (var task in group["tasks"]) {
    String room = task["room"] ?? "Unspecified";
    roomGroups.putIfAbsent(room, () => []).add(task);
  }

  // Debug: Vérifiez les groupes par pièce
  print("Room groups: $roomGroups");

  // Réorganisez les tâches en fonction des groupes
  group["tasks"] = roomGroups.values.expand((tasks) => tasks).toList();

  print("Tasks after distributeTasksByRoom: ${group['tasks']}");
}


// Helper function to prioritize weekly/daily tasks per room first
void prioritizeFrequentRoomTasks(Map<String, dynamic> group) {
  List<Map<String, dynamic>> frequentTasks = [];
  List<Map<String, dynamic>> otherTasks = [];

  // Separate weekly/daily tasks from others
  for (var task in group["tasks"]) {
    if (task["repeatUnit"] == "daily" || task["repeatUnit"] == "weekly") {
      frequentTasks.add(task);
    } else {
      otherTasks.add(task);
    }
  }

  // Arrange frequent tasks first, followed by other tasks
  group["tasks"] = [...frequentTasks, ...otherTasks];
}

// Helper function to prioritize tasks for frequently used rooms
void prioritizeHighUsageRooms(Map<String, dynamic> group, List<String> roomPriority) {
  List<Map<String, dynamic>> prioritizedTasks = [];
  List<Map<String, dynamic>> otherTasks = [];

  // Prioritize tasks based on room usage order
  for (var priorityRoom in roomPriority) {
    for (var task in group["tasks"]) {
      if (task["room"] == priorityRoom) {
        prioritizedTasks.add(task);
      }
    }
  }

  // Add remaining tasks that don’t match the priority order
  otherTasks = group["tasks"].where((task) => !prioritizedTasks.contains(task)).toList();

  // Arrange prioritized rooms' tasks first, followed by the rest
  group["tasks"] = [...prioritizedTasks, ...otherTasks];
}
