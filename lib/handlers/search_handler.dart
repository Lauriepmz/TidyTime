import 'package:tidytime/utils/all_imports.dart';

class SearchHandler {
  final TaskDetailsFetcher taskDetailsFetcher = TaskDetailsFetcher();

  // Method to route search to the correct handler
  Future<List<Task>> handleSearch(int pageIndex, String query) async {
    switch (pageIndex) {
      case 0:
        return await _searchTasks(query);  // HomePage - search by task criteria
      case 1:
        return await _searchTasks(query);  // CalendarPage - similar logic
      case 2:
        return await _searchTasks(query);  // ProfilePage - or customize it as needed
      default:
        print('Invalid page index');
        return [];
    }
  }

  // Method to search tasks by name, room, or taskType
  Future<List<Task>> _searchTasks(String query) async {
    // Fetch all tasks from the database (this could be optimized by querying the database with filters directly)
    List<Map<String, dynamic>> allTasks = await DatabaseHelper.instance.getAllTasks();

    // Convert maps to Task objects
    List<Task> tasks = allTasks.map((taskMap) => Task.fromMap(taskMap)).toList();

    // Perform filtering based on the query
    return tasks.where((task) {
      return task.taskName.toLowerCase().contains(query.toLowerCase()) ||
          task.room.toLowerCase().contains(query.toLowerCase()) ||
          (task.taskType != null && task.taskType!.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }
}
