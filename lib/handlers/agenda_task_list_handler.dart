import 'package:tidytime/utils/all_imports.dart';

class TaskHandler {
  static final TaskCompletionService _taskCompletionService = TaskCompletionService(
    DatabaseHelper.instance,
    TaskDetailsFetcher(),
  );

  // Marquer la tâche comme incomplète
  static Future<void> markTaskAsIncomplete(int taskId, Map<String, dynamic> previousTaskData) async {
    await _taskCompletionService.markTaskAsIncomplete(taskId, previousTaskData);
  }

  // Récupérer les détails d'une tâche
  static Future<Map<String, dynamic>> fetchTaskDetails(int taskId) async {
    return await _taskCompletionService.fetchTaskDetails(taskId);
  }

  // Marquer la tâche comme complétée (uniquement logique métier)
  static Future<void> markTaskAsCompleted(int taskId, Map<String, dynamic> taskData) async {
    await _taskCompletionService.markTaskAsCompleted(taskId, taskData);
  }
}
