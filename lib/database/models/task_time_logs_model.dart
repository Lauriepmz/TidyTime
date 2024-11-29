import 'package:tidytime/utils/all_imports.dart';

class TaskTimeLog {
  final int id;            // Id unique du log
  final int taskId;         // Id de la tâche provenant de la table tasks
  final DateTime logDate;   // Date du jour où le log est créé
  final int timeTook;       // Temps écoulé

  TaskTimeLog({
    required this.id,
    required this.taskId,   // Ajout du taskId pour lier le log à une tâche
    required this.logDate,
    required this.timeTook,
  });

  // Convertir un objet TaskTimeLog en map pour l'insérer dans la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,  // Insertion du taskId
      'logDate': DateHelper.dateTimeToSql(logDate),
      'timeTook': timeTook,
    };
  }

  // Convertir une map depuis la base de données en objet TaskTimeLog
  factory TaskTimeLog.fromMap(Map<String, dynamic> map) {
    return TaskTimeLog(
      id: map['id'] as int,
      taskId: map['taskId'] as int,  // Récupérer taskId
      logDate: DateHelper.sqlToDateTime(map['logDate'] as String),
      timeTook: map['timeTook'] as int,
    );
  }
}
