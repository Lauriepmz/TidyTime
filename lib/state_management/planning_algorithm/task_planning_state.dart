import 'package:tidytime/utils/all_imports.dart';

abstract class TaskPlanningState extends Equatable {
  @override
  List<Object> get props => [];
}

// État initial (aucune planification en cours)
class TaskPlanningInitial extends TaskPlanningState {}

// État indiquant que les boîtes Hive sont ouvertes et prêtes pour la planification
class TaskPlanningLoaded extends TaskPlanningState {}

class TaskPlanningProgress extends TaskPlanningState {
  final double progress;

  TaskPlanningProgress(this.progress);

  @override
  List<Object> get props => [progress];
}

// État final indiquant que la planification est terminée
class TaskPlanningCompleted extends TaskPlanningState {}

// État pour indiquer la page actuelle du quiz de préférences
class TaskPlanningPageState extends TaskPlanningState {
  final int currentPageIndex;

  TaskPlanningPageState(this.currentPageIndex);

  @override
  List<Object> get props => [currentPageIndex];
}

// État indiquant que les préférences utilisateur sont prêtes à être utilisées
class UserPreferencesReady extends TaskPlanningState {
  final Map<String, double> dailyTimeAllocation;

  UserPreferencesReady(this.dailyTimeAllocation);

  @override
  List<Object> get props => [dailyTimeAllocation];
}
// New state to handle errors
class TaskPlanningError extends TaskPlanningState {
  final String message;

  TaskPlanningError(this.message);

  @override
  List<Object> get props => [message];
}
class TasksLoadedState extends TaskPlanningState {
  final List<Map<String, dynamic>> tasks;

  TasksLoadedState({required this.tasks});
}