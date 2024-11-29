import 'package:tidytime/utils/all_imports.dart';

class TaskTimeLogger {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  int? taskTimeLogId;
  final int taskId;

  TaskTimeLogger({required this.taskId});

  // Delete all logs for a given taskId (for incomplete tasks)
  Future<void> deleteLogsForTask() async {
    final db = await DatabaseHelper.instance.database;
    try {
      await db.delete('task_time_logs', where: 'taskId = ?', whereArgs: [taskId]);
      print('Deleted logs for taskId: $taskId');
    } catch (e) {
      print('Error deleting task logs: $e');
      rethrow;
    }
  }

  // Fetch the logs of a task from the database
  Future<List<TaskTimeLog>> fetchTaskLogs() async {
    final db = await DatabaseHelper.instance.database;
    try {
      // Fetch logs based on taskId from the task_time_logs table
      final List<Map<String, dynamic>> logs = await db.query(
        'task_time_logs',
        where: 'taskId = ?',
        whereArgs: [taskId],
      );

      // Debugging: Assurez-vous que les logs sont bien récupérés
      print('Fetched ${logs.length} logs for taskId: $taskId');

      // Convert each log from Map to TaskTimeLog
      List<TaskTimeLog> taskLogs = logs.map((log) => TaskTimeLog.fromMap(log)).toList();
      return taskLogs;
    } catch (e) {
      print('Error fetching task logs: $e');
      rethrow;
    }
  }


  Future<void> insertTaskTimeLog(TaskTimeLog taskTimeLog) async {
    final db = await _databaseHelper.database;

    // Convert TaskTimeLog object to a map
    Map<String, dynamic> taskTimeLogMap = {
      'id': taskTimeLog.id,
      'taskId': taskTimeLog.taskId,
      'logDate': taskTimeLog.logDate.toIso8601String(),
      'timeTook': taskTimeLog.timeTook.toString(),
    };

    try {
      // Insert the log into the task_time_logs table
      await db.insert(
        'task_time_logs',
        taskTimeLogMap,
        conflictAlgorithm: ConflictAlgorithm.replace,  // Replace if the log already exists
      );
      print("TaskTimeLog inserted successfully: ${taskTimeLogMap['id']}");
    } catch (e) {
      print("Error inserting TaskTimeLog: $e");
    }
  }
}
