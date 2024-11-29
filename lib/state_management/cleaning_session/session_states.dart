import 'package:tidytime/utils/all_imports.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionError extends SessionState {
  final String errorMessage;

  const SessionError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class SessionInProgress extends SessionState {
  final List<Task> tasks;
  final List<int> completedTaskIds;
  final DateTime startTime;
  final Map<int, String> elapsedTimeMap;

  const SessionInProgress(this.tasks, this.completedTaskIds, this.elapsedTimeMap, this.startTime);

  @override
  List<Object?> get props => [tasks, completedTaskIds, elapsedTimeMap, startTime];
}

class SessionPaused extends SessionState {
  final String formattedTime;

  const SessionPaused(this.formattedTime);

  @override
  List<Object?> get props => [formattedTime];
}

class SessionStopped extends SessionState {
  final DateTime endTime;

  const SessionStopped(this.endTime);

  @override
  List<Object?> get props => [endTime];
}

class SessionCanceled extends SessionState {
  const SessionCanceled();

  @override
  List<Object> get props => [];
}

class TaskUpdated extends SessionState {
  final List<Task> tasks;
  final List<int> completedTaskIds;

  const TaskUpdated(this.tasks, this.completedTaskIds);

  @override
  List<Object?> get props => [tasks, completedTaskIds];
}

class SessionFloatingVisibilityChanged extends SessionState {
  final bool isFloatingVisible;

  const SessionFloatingVisibilityChanged(this.isFloatingVisible);
}
