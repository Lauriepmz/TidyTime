import 'package:tidytime/utils/all_imports.dart';

class TaskService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TaskDetailsFetcher _taskDetailsFetcher = TaskDetailsFetcher();

  Future<List<String>> getRoomsWithTasks() async {
    return await _dbHelper.getRoomsWithTasks();
  }

  Future<int> calculateOverdueTasks() async {
    final tasks = await _dbHelper.getAllTasks();  // Fetch all tasks
    final userSettings = UserSettings();  // Get user settings
    final dueDateMethod = await userSettings.getDueDateCalculationMethod();  // Fetch due date calculation method

    int overdueCount = 0;
    DateTime today = DateTime.now();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

    for (var task in tasks) {
      final taskDetails = await _taskDetailsFetcher.fetchTaskDetails(task['id'] as int);

      DateTime? dueDate;
      if (dueDateMethod == UserSettings.dueDateLastDone) {
        dueDate = taskDetails['dueDateLastDone'] as DateTime?;
      } else if (dueDateMethod == UserSettings.dueDateLastDoneProposed) {
        dueDate = taskDetails['dueDateLastDoneProposed'] as DateTime?;
      }

      // Debugging: Print due dates and comparison
      print('Task ID: ${task['id']} - Due Date: $dueDate - Today: $todayWithoutTime');

      if (dueDate != null && dueDate.isBefore(todayWithoutTime)) {
        overdueCount++;
      }
    }

    return overdueCount;
  }

// Method to calculate tasks due within a date range (including overdue tasks)
  Future<int> calculateTotalTasksInRange(DateTime endDate) async {
    final tasks = await _dbHelper.getAllTasks();
    final userSettings = UserSettings();
    final dueDateMethod = await userSettings.getDueDateCalculationMethod();

    int totalTasksInRange = 0;

    for (var task in tasks) {
      final taskDetails = await _taskDetailsFetcher.fetchTaskDetails(task['id'] as int);
      DateTime? dueDate;

      if (dueDateMethod == UserSettings.dueDateLastDone) {
        dueDate = taskDetails['dueDateLastDone'] as DateTime?;
      } else if (dueDateMethod == UserSettings.dueDateLastDoneProposed) {
        dueDate = taskDetails['dueDateLastDoneProposed'] as DateTime?;
      }

      if (dueDate != null) {
        DateTime dueDateWithoutTime = DateTime(dueDate.year, dueDate.month, dueDate.day);

        // Count tasks due on or before the end date (including overdue tasks)
        if (dueDateWithoutTime.isBefore(endDate.add(Duration(days: 1)))) {
          totalTasksInRange++;
        }
      }
    }

    return totalTasksInRange;
  }

  // Method to calculate tasks completed within a date range
  Future<int> calculateCompletedTasksInRange(DateTime startDate, DateTime endDate) async {
    final tasks = await _dbHelper.getAllTasks();
    int completedTasksInRange = 0;

    for (var task in tasks) {
      final taskDetails = await _taskDetailsFetcher.fetchTaskDetails(task['id'] as int);
      DateTime? lastDone = taskDetails['lastDone'] as DateTime?;

      if (lastDone != null) {
        DateTime lastDoneWithoutTime = DateTime(lastDone.year, lastDone.month, lastDone.day);

        // Count tasks completed within the specified range
        if (lastDoneWithoutTime.isAfter(startDate.subtract(Duration(days: 1))) && lastDoneWithoutTime.isBefore(endDate.add(Duration(days: 1)))) {
          completedTasksInRange++;
        }
      }
    }
    return completedTasksInRange;
  }

  // Method to check if tasks exist
  Future<bool> hasTasks() async {
    final tasks = await _dbHelper.getAllTasks();
    return tasks.isNotEmpty;
  }


  Future<List<Map<String, dynamic>>> getTasksDueTodayOrOverdue() async {
    // Fetch all tasks from the database
    final tasks = await _dbHelper.getAllTasks();

    // Fetch user settings to determine the due date calculation method
    final userSettings = UserSettings();
    final dueDateMethod = await userSettings.getDueDateCalculationMethod();

    // Debug: Afficher la méthode de calcul de la due date
    print("User due date method: ${dueDateMethod == UserSettings.dueDateLastDone ? 'dueDateLastDone' : 'dueDateLastDoneProposed'}");

    List<Map<String, dynamic>> overdueTasks = [];

    // Obtenir la date actuelle sans composant temporel (00:00:00)
    DateTime currentDateWithoutTime = DateTime.now();
    currentDateWithoutTime = DateTime(currentDateWithoutTime.year, currentDateWithoutTime.month, currentDateWithoutTime.day);

    for (var task in tasks) {
      // Fetch task details using TaskDetailsFetcher (this handles data conversion)
      final taskDetails = await _taskDetailsFetcher.fetchTaskDetails(task['id'] as int);
      DateTime? dueDate;

      // Debug: Afficher les détails de la tâche récupérée
      print("Task ID: ${task['id']}, Task Name: ${taskDetails['taskName']}");

      // Determine which due date calculation method to use
      if (dueDateMethod == UserSettings.dueDateLastDone) {
        dueDate = taskDetails['dueDateLastDone'] as DateTime?;
      } else if (dueDateMethod == UserSettings.dueDateLastDoneProposed) {
        dueDate = taskDetails['dueDateLastDoneProposed'] as DateTime?;
      }

      // Debug: Afficher la due date récupérée pour chaque tâche
      if (dueDate != null) {
        print("Task ID: ${task['id']} has due date: $dueDate");
      } else {
        print("Task ID: ${task['id']} has no due date.");
      }

      // Continue to next task if dueDate is null (ignore tasks without a due date)
      if (dueDate != null) {
        // Remove time component from dueDate for accurate comparison
        DateTime dueDateWithoutTime = DateTime(dueDate.year, dueDate.month, dueDate.day);

        // Debug: Afficher la comparaison avec la date actuelle sans heure
        print("Comparing task's dueDateWithoutTime: $dueDateWithoutTime with currentDateWithoutTime: $currentDateWithoutTime");

        // Only add tasks that are due today or overdue
        if (dueDateWithoutTime.isBefore(currentDateWithoutTime.add(const Duration(days: 1)))) {
          overdueTasks.add(taskDetails);
          print("Task ID: ${task['id']} is overdue or due today.");
        } else {
          print("Task ID: ${task['id']} is not overdue.");
        }
      }
    }

    return overdueTasks;
  }

  Future<int> addTask(Task task) async {
    // Insert the task into the database using the DatabaseHelper class
    return await _dbHelper.insertTask(task);
  }

  Future<void> deleteTask(BuildContext context, int taskId) async {
    try {
      await _dbHelper.deleteTask(taskId);
    } catch (e) {
      debugPrint("Error occurred while deleting task: $e");
      throw Exception("Failed to delete task");
    }
  }
}
