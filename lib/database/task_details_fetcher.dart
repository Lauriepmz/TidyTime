import 'package:tidytime/utils/all_imports.dart';

class TaskDetailsFetcher {
  // Existing method for fetching a single task by ID
  Future<Map<String, dynamic>> fetchTaskDetails(int taskId) async {
    final task = await DatabaseHelper.instance.getTaskById(taskId);
    if (task == null) {
      throw Exception('Task not found');
    }
    return _convertTaskDates(task);
  }

  // New method to fetch all tasks with correct date formatting
  Future<List<Map<String, dynamic>>> fetchAllTasks() async {
    final tasks = await DatabaseHelper.instance.getAllTasks(); // Fetches all tasks from SQLite
    return tasks.map((task) => _convertTaskDates(task)).toList();
  }

  // Private helper to convert date fields in a task map
  Map<String, dynamic> _convertTaskDates(Map<String, dynamic> task) {
    task['startDate'] = task['startDate'] is String
        ? DateHelper.sqlToDateTime(task['startDate'] as String)
        : task['startDate'];
    task['dueDateLastDone'] = task['dueDateLastDone'] is String
        ? DateHelper.sqlToDateTime(task['dueDateLastDone'] as String)
        : task['dueDateLastDone'];
    task['lastDone'] = task['lastDone'] is String
        ? DateHelper.sqlToDateTime(task['lastDone'] as String)
        : task['lastDone'];
    task['lastDoneProposed'] = task['lastDoneProposed'] is String
        ? DateHelper.sqlToDateTime(task['lastDoneProposed'] as String)
        : task['lastDoneProposed'];
    task['dueDateLastDoneProposed'] = task['dueDateLastDoneProposed'] is String
        ? DateHelper.sqlToDateTime(task['dueDateLastDoneProposed'] as String)
        : task['dueDateLastDoneProposed'];
    return Map<String, dynamic>.from(task);
  }
}
