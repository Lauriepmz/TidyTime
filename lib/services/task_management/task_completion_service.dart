import 'package:tidytime/utils/all_imports.dart';

class TaskCompletionService {
  final DatabaseHelper _databaseHelper;
  final TaskDetailsFetcher _taskDetailsFetcher;

  TaskCompletionService(this._databaseHelper, this._taskDetailsFetcher);

  // Marquer une tâche comme complétée et journaliser la complétion
  Future<void> markTaskAsCompleted(int taskId, taskData) async {
    print("---- TaskCompletionService: Marking task as completed ----");

    // Récupérer les détails de la tâche
    Map<String, dynamic> task = await _taskDetailsFetcher.fetchTaskDetails(taskId);
    DateTime currentDate = DateTime.now();

    // Recalculer les dates d'échéance
    Map<String, DateTime?> recalculatedDates = DateCalculator.calculateCompletionDueDates(
      currentDate: currentDate,
      lastDone: task['lastDone'] ?? currentDate,
      lastDoneProposed: task['lastDoneProposed'] ?? task['startDate'] ?? currentDate,
      repeatDays: task['repeatValue'] * _databaseHelper.convertUnitToDays(task['repeatUnit']),
      startDate: task['startDate'] ?? currentDate,
    );

    // Mise à jour de la tâche dans la base de données
    await _databaseHelper.updateTaskCompletion(
      taskId,
      lastDone: currentDate,
      lastDoneProposed: recalculatedDates['lastDoneProposed'],
      dueDateLastDone: recalculatedDates['dueDateLastDone'],
      dueDateLastDoneProposed: recalculatedDates['dueDateLastDoneProposed'],
    );

    // Journaliser la complétion
    final completionLog = CompletionLog(taskId);
    await completionLog.logCompletion(currentDate);

    print("Task ID $taskId updated with new due dates and completion logged at $currentDate");
  }

  Future<void> markTaskAsIncomplete(int taskId, Map<String, dynamic> previousTaskData) async {
    print("---- TaskCompletionService: Marking task as incomplete ---- for taskId: $taskId");
    print("Previous task data: $previousTaskData");

    try {
      // Safely parse previous task data
      DateTime? lastDone = previousTaskData['lastDone'] != null
          ? DateTime.tryParse(previousTaskData['lastDone'])
          : null;

      DateTime? lastDoneProposed = previousTaskData['lastDoneProposed'] != null
          ? DateTime.tryParse(previousTaskData['lastDoneProposed'])
          : null;

      DateTime? dueDateLastDone = previousTaskData['dueDateLastDone'] != null
          ? DateTime.tryParse(previousTaskData['dueDateLastDone'])
          : null;

      DateTime? dueDateLastDoneProposed = previousTaskData['dueDateLastDoneProposed'] != null
          ? DateTime.tryParse(previousTaskData['dueDateLastDoneProposed'])
          : null;

      // If fields were initially null, reset them to null
      if (previousTaskData['lastDone'] == null) {
        lastDone = null;
      }
      if (previousTaskData['lastDoneProposed'] == null) {
        lastDoneProposed = null;
      }
      if (previousTaskData['dueDateLastDone'] == null) {
        dueDateLastDone = null;
      }
      if (previousTaskData['dueDateLastDoneProposed'] == null) {
        dueDateLastDoneProposed = null;
      }

      // Update the task in the database
      await _databaseHelper.updateTaskCompletion(
        taskId,
        lastDone: lastDone ?? DateTime.now(), // If null, reset
        lastDoneProposed: lastDoneProposed,
        dueDateLastDone: dueDateLastDone,
        dueDateLastDoneProposed: dueDateLastDoneProposed,
      );

      // Remove the last completion log
      final completionLog = CompletionLog(taskId);
      await completionLog.removeLastCompletion();

      print("Task ID $taskId restored to its previous state, and last completion log removed.");
    } catch (e) {
      print("Error while undoing task completion for taskId $taskId: $e");
    }
  }

  // Fetch task details using TaskDetailsFetcher
  Future<Map<String, dynamic>> fetchTaskDetails(int taskId) async {
    return await _taskDetailsFetcher.fetchTaskDetails(taskId);
  }
}
