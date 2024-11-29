import 'package:tidytime/utils/all_imports.dart';

class AgendaTaskService {
  static Future<void> markTaskAsCompleted({
    required BuildContext context,
    required Task task,
    required VoidCallback onTaskUpdated,
  }) async {
    print('Fetching task details for task ID: ${task.id}');

    // Fetch task details
    final Map<String, dynamic> taskData = await TaskHandler.fetchTaskDetails(task.id!);

    // Save the previous state of the task
    Map<String, dynamic> previousTaskData = {
      'lastDone': taskData['lastDone'],
      'lastDoneProposed': taskData['lastDoneProposed'],
      'dueDateLastDone': taskData['dueDateLastDone'],
      'dueDateLastDoneProposed': taskData['dueDateLastDoneProposed'],
    };

    print('Marking task as completed: ${task.taskName}');

    // Call TaskHandler to mark the task as completed
    await TaskHandler.markTaskAsCompleted(task.id!, taskData);

    // Show the BottomSheet with the Undo option
    TaskBottomSheetService.showUndoBottomSheet(
      context: context,
      message: 'Task marked as completed',
      undoCallback: () async {
        // Call TaskHandler to undo the task completion
        await TaskHandler.markTaskAsIncomplete(task.id!, previousTaskData);
      },
      onUndoSuccess: () {
        // Trigger UI refresh on Undo success
        onTaskUpdated();
      },
    );

    print('Task marked as completed for task ID: ${task.id}');
  }

  // Méthode pour naviguer vers la page des détails de la tâche
  static void navigateToTaskDetail(BuildContext context, int taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(taskId: taskId),
      ),
    );
  }
}
