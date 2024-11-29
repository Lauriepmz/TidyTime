import 'package:tidytime/utils/all_imports.dart';

class CompletionLog {
  final int taskId;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  CompletionLog(this.taskId);

  // Fetch all completion dates for a specific task
  Future<List<DateTime>> getCompletionDates() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> logs = await db.query(
      'completion_logs',
      where: 'taskId = ?',
      whereArgs: [taskId],
      orderBy: 'completionDate DESC', // Order by most recent completion
    );

    print("Fetched ${logs.length} logs for taskId: $taskId");

    return logs.map((log) => DateHelper.sqlToDateTime(log['completionDate'])).toList();
  }

  Future<void> logCompletion(DateTime completionDate) async {
    final db = await _dbHelper.database;

    // Convert completionDate to a string to match the format used in the database
    String formattedCompletionDate = DateHelper.dateTimeToSql(completionDate);

    // Check if this completion date already exists in the log for this task
    final existingLogs = await db.query(
      'completion_logs',
      where: 'taskId = ? AND DATE(completionDate) = DATE(?)', // Check if there's a log with the same taskId and completionDate
      whereArgs: [taskId, formattedCompletionDate],
    );

    // If no existing log is found for the same date, proceed with insertion
    if (existingLogs.isEmpty) {
      await db.insert(
        'completion_logs',
        {
          'taskId': taskId,
          'completionDate': formattedCompletionDate,
        },
      );
      print("Inserted log for taskId: $taskId at $completionDate");
    } else {
      print("Log already exists for taskId: $taskId at $completionDate. Skipping insertion.");
    }
  }

  Future<void> removeLastCompletion() async {
    final db = await _dbHelper.database;

    // Get the most recent completion log for the task
    final result = await db.query(
      'completion_logs',
      where: 'taskId = ?',
      whereArgs: [taskId],
      orderBy: 'completionDate DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      final int logId = result.first['id'] as int; // Explicitly cast to int
      await db.delete(
        'completion_logs',
        where: 'id = ?',
        whereArgs: [logId],
      );
      print("Removed the last completion log (ID: $logId) for taskId: $taskId");
    } else {
      print("No completion logs found to remove for taskId: $taskId");
    }
  }
}
