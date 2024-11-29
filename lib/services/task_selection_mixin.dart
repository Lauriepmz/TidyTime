import 'package:tidytime/utils/all_imports.dart';

mixin TaskSelectionMixin<T extends StatefulWidget> on State<T> {
  Set<int> selectedTaskIds = {};
  bool isSelectionMode = false;  // État pour suivre si le mode de sélection est actif

  void toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedTaskIds.clear();  // Nettoyer la sélection si nous sortons du mode de sélection
      }
    });
  }

  void toggleTaskSelection(int taskId) {
    setState(() {
      if (selectedTaskIds.contains(taskId)) {
        selectedTaskIds.remove(taskId);
      } else {
        selectedTaskIds.add(taskId);
      }
      if (selectedTaskIds.isEmpty) {
        isSelectionMode = false;  // Désactiver le mode de sélection si aucun élément n'est sélectionné
      }
    });
  }

  Future<void> deleteSelectedTasks() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${selectedTaskIds.length} task(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final taskService = TaskService();
      for (int taskId in selectedTaskIds) {
        await taskService.deleteTask(context, taskId);
      }
      refreshTasks();
    }
  }

  void refreshTasks();
}
