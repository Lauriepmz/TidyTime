import 'package:tidytime/utils/all_imports.dart';

Future<void> logTasksAndUpdateStartDates(
    List<Map<String, dynamic>> allTasks,
    Map<int, DateTime> tempStartDates, // Map contenant les dates de début calculées pour chaque tâche
    DatabaseHelper databaseHelper, // Utilisé pour manipuler les tâches dans SQLite
    TaskDetailsFetcher taskDetailsFetcher, // Pour récupérer les détails d'une tâche existante
    ) async {
  for (var taskData in allTasks) {
    int? taskId = taskData["id"] as int?;
    DateTime startDate = tempStartDates[taskId] ?? DateTime.now();

    try {
      if (taskId != null) {
        try {
          // Vérifier si la tâche existe déjà dans la base de données
          Map<String, dynamic> existingTaskDetails =
          await taskDetailsFetcher.fetchTaskDetails(taskId);

          if (existingTaskDetails.isNotEmpty) {
            // Mise à jour des champs nécessaires pour une tâche existante
            if (existingTaskDetails["lastDone"] == null) {
              // Si la tâche n'a jamais été complétée
              existingTaskDetails["startDate"] = startDate;

              // Mise à jour dans la base de données
              await databaseHelper.updateTask(
                taskId,
                Task.fromMap(existingTaskDetails),
              );
            } else {
              // Si `lastDone` est déjà défini
              existingTaskDetails["dueDateLastDone"] = startDate;
              existingTaskDetails["dueDateLastDoneProposed"] = startDate;

              // Mise à jour dans la base de données
              await databaseHelper.updateTask(
                taskId,
                Task.fromMap(existingTaskDetails),
              );
            }
          } else {
            throw Exception("Task not found");
          }
        } catch (e) {
          // Créer une nouvelle tâche si elle n'existe pas
          await _createNewTask(taskData, startDate, databaseHelper);
        }
      } else {
        // Nouvelle tâche sans ID
        await _createNewTask(taskData, startDate, databaseHelper);
      }
    } catch (e) {
      // Gestion des erreurs
    }
  }
}

/// Méthode pour créer une nouvelle tâche
Future<void> _createNewTask(
    Map<String, dynamic> taskData,
    DateTime startDate,
    DatabaseHelper databaseHelper,
    ) async {
  try {
    Task newTask = Task(
      id: null, // ID sera auto-généré
      taskName: taskData["taskName"],
      room: taskData["room"],
      repeatValue: taskData["repeatValue"],
      repeatUnit: taskData["repeatUnit"],
      startDate: startDate,
      dueDateLastDone: null,
      dueDateLastDoneProposed: null,
      lastDone: null,
      lastDoneProposed: null,
      taskType: taskData["taskType"],
    );

    await databaseHelper.insertTask(newTask);
  } catch (e) {
    rethrow;
  }
}
