class TaskValidator {
  /// Validates that all tasks in a group have the necessary fields.
  static void validateTasks(List<Map<String, dynamic>> tasks) {
    for (var task in tasks) {
      if (!task.containsKey("taskName") || task["taskName"] == null) {
        throw Exception("Task is missing a 'taskName'.");
      }

      if (!task.containsKey("repeatUnit") || task["repeatUnit"] == null) {
        throw Exception("Task '${task["taskName"]}' is missing a 'repeatUnit'.");
      }

      if (!task.containsKey("repeatValue") || task["repeatValue"] == null) {
        throw Exception("Task '${task["taskName"]}' is missing a 'repeatValue'.");
      }

      if (!task.containsKey("id") || task["id"] == null) {
        throw Exception("Task '${task["taskName"]}' is missing an 'id'.");
      }
    }
  }

  /// Ensures all group keys exist and contain valid tasks.
  static void validateGroupData(Map<String, Map<String, dynamic>> groupData) {
    if (groupData.isEmpty) {
      throw Exception("Group data cannot be empty.");
    }

    for (var entry in groupData.entries) {
      String groupName = entry.key;
      var group = entry.value;

      if (!group.containsKey("tasks") || group["tasks"] == null) {
        continue;
      }

      List<Map<String, dynamic>> tasks = List<Map<String, dynamic>>.from(group["tasks"] ?? []);
      if (tasks.isEmpty) {
        print("Warning: Group '$groupName' has an empty task list.");
        continue;
      }

      validateTasks(tasks);
    }

    print("All group data validated successfully.");
  }
}
