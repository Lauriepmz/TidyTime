import 'package:tidytime/utils/all_imports.dart';

class AgendaService {
  static Future<List<Task>> getTasksForDay(DateTime selectedDay) async {
    final db = await DatabaseHelper.instance.database;

    // Récupérer la méthode de calcul choisie par l'utilisateur
    final userSettings = UserSettings();
    String dueDateCalculationMethod = await userSettings.getDueDateCalculationMethod();

    // Déterminer quelle colonne de dueDate utiliser
    final String queryColumn = (dueDateCalculationMethod == UserSettings.dueDateLastDone)
        ? 'dueDateLastDone'
        : 'dueDateLastDoneProposed';

    // Convertir la date sélectionnée en 'yyyy-MM-dd'
    final String formattedSelectedDay = DateHelper.dateTimeToString(selectedDay);

    print('Selected day for task query: $formattedSelectedDay using $queryColumn');

    // Utiliser la fonction DATE() pour comparer uniquement la partie jour
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'DATE($queryColumn) = ?',
      whereArgs: [formattedSelectedDay],
    );

    print('Fetched tasks: ${maps.length} tasks found for the selected day.');
    for (var map in maps) {
      final task = Task.fromMap(map);
      print(
          'Task "${task.taskName}" - Due Date: ${task.dueDate} / Start Date: ${task.startDate}');
    }

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // Charger les tâches complétées pour une date spécifique
  static Future<List<Task>> getTasksCompletedForDate(DateTime selectedDay) async {
    final db = await DatabaseHelper.instance.database;

    // Convertir la date sélectionnée en 'yyyy-MM-dd'
    final String formattedSelectedDay = DateHelper.dateTimeToString(selectedDay);

    // Requête pour récupérer les tâches avec une date de complétion correspondant à la date sélectionnée
    final List<Map<String, dynamic>> logs = await db.rawQuery('''
      SELECT tasks.* FROM tasks
      JOIN completion_logs ON tasks.id = completion_logs.taskId
      WHERE DATE(completion_logs.completionDate) = ?
    ''', [formattedSelectedDay]);

    print('Fetched ${logs.length} completed tasks for the selected day.');

    return logs.map((log) => Task.fromMap(log)).toList();
  }

  // Charger toutes les tâches pour une plage de dates spécifiques
  static Future<Map<DateTime, List<Task>>> getTasksForDateRange(DateTime firstDay, DateTime lastDay) async {
    final db = await DatabaseHelper.instance.database;

    // Récupérer la méthode de calcul choisie par l'utilisateur
    final userSettings = UserSettings();
    String dueDateCalculationMethod = await userSettings.getDueDateCalculationMethod();

    // Déterminer quelle colonne de dueDate utiliser
    final String queryColumn = (dueDateCalculationMethod == UserSettings.dueDateLastDone)
        ? 'dueDateLastDone'
        : 'dueDateLastDoneProposed';

    // Récupérer toutes les tâches dans la plage de dates
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM tasks
      WHERE DATE($queryColumn) BETWEEN ? AND ?
    ''', [DateHelper.dateTimeToString(firstDay), DateHelper.dateTimeToString(lastDay)]);

    print('Fetched tasks for range: ${maps.length} tasks found.');

    // Créer un map avec la date comme clé et la liste des tâches comme valeur
    Map<DateTime, List<Task>> tasksByDate = {};

    for (var map in maps) {
      Task task = Task.fromMap(map);
      DateTime? dueDate = (dueDateCalculationMethod == UserSettings.dueDateLastDone)
          ? task.dueDateLastDone
          : task.dueDateLastDoneProposed;

      if (dueDate != null) {
        DateTime dateKey = DateTime(dueDate.year, dueDate.month, dueDate.day);
        if (tasksByDate.containsKey(dateKey)) {
          tasksByDate[dateKey]!.add(task);
        } else {
          tasksByDate[dateKey] = [task];
        }
      }
    }

    return tasksByDate;
  }
  static Future<List<Task>> getOverdueTasks(DateTime currentDate) async {
    final db = await DatabaseHelper.instance.database;

    // Récupérer la méthode de calcul choisie par l'utilisateur
    final userSettings = UserSettings();
    String dueDateCalculationMethod = await userSettings.getDueDateCalculationMethod();

    // Déterminer quelle colonne utiliser pour dueDate
    final String queryColumn = (dueDateCalculationMethod == UserSettings.dueDateLastDone)
        ? 'dueDateLastDone'
        : 'dueDateLastDoneProposed';

    print('Fetching overdue tasks with current date: ${currentDate.toIso8601String()}');

    // Requête SQL pour les tâches en retard
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT * FROM tasks
    WHERE $queryColumn < ?
  ''', [currentDate.toIso8601String()]);

    print('Fetched ${maps.length} overdue tasks.');
    for (var map in maps) {
      final task = Task.fromMap(map);
      print(
          'Overdue Task "${task.taskName}" - Due Date: ${task.dueDate} / Start Date: ${task.startDate}');
    }

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  static Future<int> calculateTotalTasksForToday(DateTime today) async {
    final db = await DatabaseHelper.instance.database;

    // Normaliser la date d'aujourd'hui (sans l'heure)
    final DateTime normalizedToday = DateTime(today.year, today.month, today.day);

    // Déterminer la colonne dueDate selon les préférences utilisateur
    final userSettings = UserSettings();
    String dueDateColumn = await userSettings.getDueDateCalculationMethod() == UserSettings.dueDateLastDone
        ? 'dueDateLastDone'
        : 'dueDateLastDoneProposed';

    // Requête SQL pour récupérer les tâches dues jusqu'à aujourd'hui
    final List<Map<String, dynamic>> tasks = await db.rawQuery('''
    SELECT * FROM tasks
    WHERE DATE($dueDateColumn) <= ?
  ''', [DateHelper.dateTimeToString(normalizedToday)]);

    // Total des tâches trouvées
    final int totalTasks = tasks.length;

    print('Total tasks calculated for today: $totalTasks');
    return totalTasks;
  }
}
