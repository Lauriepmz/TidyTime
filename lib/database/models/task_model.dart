import 'package:tidytime/utils/all_imports.dart';

class Task {
  int? id;
  String taskName;
  String room;
  int repeatValue;
  String repeatUnit;
  DateTime startDate;
  final DateTime? _dueDateLastDone;
  final DateTime? _dueDateLastDoneProposed;
  final DateTime? _lastDone;
  final DateTime? _lastDoneProposed;
  String? taskType;

  Task({
    this.id,
    required this.taskName,
    required this.room,
    required this.repeatValue,
    required this.repeatUnit,
    required this.startDate,
    DateTime? dueDateLastDone,
    DateTime? dueDateLastDoneProposed,
    DateTime? lastDone,
    DateTime? lastDoneProposed,
    this.taskType,
  })  : _dueDateLastDone = dueDateLastDone,
        _dueDateLastDoneProposed = dueDateLastDoneProposed,
        _lastDone = lastDone,
        _lastDoneProposed = lastDoneProposed;

  // Getters for accessing these private fields
  DateTime? get lastDone => _lastDone;
  DateTime? get lastDoneProposed => _lastDoneProposed;
  DateTime? get dueDateLastDone => _dueDateLastDone;
  DateTime? get dueDateLastDoneProposed => _dueDateLastDoneProposed;

  // Getter for generic due date based on user's calculation method
  DateTime? get dueDate {
    return _dueDateLastDone ?? _dueDateLastDoneProposed;
  }

  // Méthode pour obtenir le nom de la tâche traduit dynamiquement
  Future<String> getTranslatedName(String targetLanguage) async {
    try {
      return await TranslationService.translateText(taskName, targetLanguage);
    } catch (e) {
      print("Error translating task name: $e");
      return taskName; // Retourne le nom d'origine en cas d'erreur
    }
  }

  // Method to convert a Map into a Task object
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      taskName: map['taskName'] ?? 'Unnamed Task',
      room: map['room'] ?? 'Unknown Room',
      repeatValue: map['repeatValue'] ?? 1,
      repeatUnit: map['repeatUnit'] ?? 'days',
      startDate: map['startDate'] is String
          ? DateHelper.sqlToDateTime(map['startDate'] as String)
          : map['startDate'],
      dueDateLastDone: map['dueDateLastDone'] != null
          ? (map['dueDateLastDone'] is String
          ? DateHelper.sqlToDateTime(map['dueDateLastDone'] as String)
          : map['dueDateLastDone'])
          : null,
      dueDateLastDoneProposed: map['dueDateLastDoneProposed'] != null
          ? (map['dueDateLastDoneProposed'] is String
          ? DateHelper.sqlToDateTime(map['dueDateLastDoneProposed'] as String)
          : map['dueDateLastDoneProposed'])
          : null,
      lastDone: map['lastDone'] != null
          ? (map['lastDone'] is String
          ? DateHelper.sqlToDateTime(map['lastDone'] as String)
          : map['lastDone'])
          : null,
      lastDoneProposed: map['lastDoneProposed'] != null
          ? (map['lastDoneProposed'] is String
          ? DateHelper.sqlToDateTime(map['lastDoneProposed'] as String)
          : map['lastDoneProposed'])
          : null,
      taskType: map['taskType'],
    );
  }

  // Method to convert the Task object to a Map (for database storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskName': taskName,
      'room': room,
      'repeatValue': repeatValue,
      'repeatUnit': repeatUnit,
      'startDate': DateHelper.dateTimeToSql(startDate),
      'dueDateLastDone': _dueDateLastDone != null ? DateHelper.dateTimeToSql(_dueDateLastDone) : null,
      'dueDateLastDoneProposed': _dueDateLastDoneProposed != null
          ? DateHelper.dateTimeToSql(_dueDateLastDoneProposed)
          : null,
      'lastDone': _lastDone != null ? DateHelper.dateTimeToSql(_lastDone) : null,
      'lastDoneProposed': _lastDoneProposed != null ? DateHelper.dateTimeToSql(_lastDoneProposed) : null,
      'taskType': taskType,
    };
  }
}
