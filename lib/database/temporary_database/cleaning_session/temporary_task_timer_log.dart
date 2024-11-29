import 'package:tidytime/utils/all_imports.dart';

part 'temporary_task_timer_log.g.dart';  // Ce fichier sera généré

@HiveType(typeId: 0)
class TemporaryTaskTimerLog {
  @HiveField(0)
  final int taskId;

  @HiveField(1)
  int startTime;  // Stocke le temps écoulé en secondes depuis le début du chronomètre

  @HiveField(2)
  int endTime;  // Stocke le temps écoulé en secondes au moment où la tâche est marquée comme terminée

  @HiveField(3)
  int elapsedTime;  // Stocke le temps total écoulé entre startTime et endTime

  @HiveField(4)
  bool status;

  TemporaryTaskTimerLog({
    required this.taskId,
    required this.startTime,  // Temps initial du chronomètre en secondes
    required this.endTime,    // Temps final du chronomètre en secondes
    required this.elapsedTime,
    required this.status,
  });

  // Mettre à jour elapsedTime en fonction des valeurs de startTime et endTime
  void updateElapsedTime() {
    elapsedTime = endTime - startTime;  // Calculer le temps écoulé en secondes
  }
}
