import 'package:tidytime/utils/all_imports.dart';

class TaskManagementHandler {
  final TaskCompletionService _taskCompletionService;
  final TaskDetailsFetcher _taskDetailsFetcher = TaskDetailsFetcher();

  TaskManagementHandler(this._taskCompletionService);

  // Récupérer les détails d'une tâche
  Future<Map<String, dynamic>> fetchTaskDetails(int taskId) async {
    return await _taskDetailsFetcher.fetchTaskDetails(taskId);  // Utiliser TaskDetailsFetcher pour récupérer les détails
  }

  // Convertir les détails récupérés en objet Task
  Future<Task> getTaskObject(int taskId) async {
    final taskData = await fetchTaskDetails(taskId);
    return Task.fromMap(taskData);
  }

  Future<void> markTaskAsCompleted(
      BuildContext context,
      Task task,
      VoidCallback onTaskUpdated, // Callback pour rafraîchir la page
      ) async {
    Map<String, dynamic> taskData = task.toMap();

    // Stocker les données avant la complétion
    final previousTaskData = {
      'lastDone': taskData['lastDone'],
      'lastDoneProposed': taskData['lastDoneProposed'],
      'dueDateLastDone': taskData['dueDateLastDone'],
      'dueDateLastDoneProposed': taskData['dueDateLastDoneProposed'],
    };

    // Marquer la tâche comme complétée
    await _taskCompletionService.markTaskAsCompleted(task.id!, taskData);

    // Appeler le BottomSheet pour annuler la complétion
    TaskBottomSheetService.showUndoBottomSheet(
      context: context,
      message: 'Task marked as completed',
      undoCallback: () async {
        // Annuler la complétion
        await _taskCompletionService.markTaskAsIncomplete(task.id!, previousTaskData);
      },
      onUndoSuccess: () {
        // Notifier le succès pour rafraîchir la page
        onTaskUpdated();
      },
    );
  }


  // Marquer une tâche comme incomplète (undo)
  Future<void> markTaskAsIncomplete(int taskId, Map<String, dynamic> previousTaskData) async {
    await _taskCompletionService.markTaskAsIncomplete(taskId, previousTaskData);  // Utiliser TaskCompletionService
  }

  // Supprimer une tâche
  Future<void> deleteTask(int taskId) async {
    await DatabaseHelper.instance.deleteTask(taskId);  // Supprimer la tâche de la base de données
  }

  // Éditer une tâche
  Future<void> editTask(int taskId, Task updatedTask) async {
    await DatabaseHelper.instance.updateTask(taskId, updatedTask);
  }

  // Fetch the task completion log (all lastDone entries)
  Future<List<DateTime>> fetchCompletionLog(int taskId) async {
    final completionLog = CompletionLog(taskId);
    return await completionLog.getCompletionDates();
  }
}
