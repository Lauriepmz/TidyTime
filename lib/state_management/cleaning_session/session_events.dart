import 'package:tidytime/utils/all_imports.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object> get props => [];
}

class StartSession extends SessionEvent {
  final List<Task>? modifiedTasks;  // Optionally pass the modified task list

  const StartSession({this.modifiedTasks});
}

class SaveSession extends SessionEvent {}

class PauseSession extends SessionEvent {
  const PauseSession();  // Mark constructor as const
}

class StopSession extends SessionEvent {
  final DateTime endTime;
  final BuildContext context;  // Add context for navigation

  const StopSession(this.endTime, this.context);

  @override
  List<Object> get props => [endTime];
}

class ResumeSession extends SessionEvent {
  const ResumeSession();  // Mark constructor as const
}

// Événement pour annuler la session
class CancelSession extends SessionEvent {
  final DateTime cancelTime;

  const CancelSession(this.cancelTime);

  @override
  List<Object> get props => [cancelTime];
}

class UpdateTaskStatus extends SessionEvent {
  final int taskId;
  final bool isCompleted;

  const UpdateTaskStatus(this.taskId, this.isCompleted);

  @override
  List<Object> get props => [taskId, isCompleted];
}

class UpdateTimer extends SessionEvent {
  final int elapsedTime;  // Time in seconds

  const UpdateTimer(this.elapsedTime);

  @override
  List<Object> get props => [elapsedTime];
}

// Mise à jour pour aligner avec _isFloatingVisible dans SessionBloc
class ToggleFloatingVisibilityEvent extends SessionEvent {
  final bool isFloatingVisible;  // Changed to align with _isFloatingVisible

  const ToggleFloatingVisibilityEvent(this.isFloatingVisible);

  @override
  List<Object> get props => [isFloatingVisible];
}

class ToggleFullScreenEvent extends SessionEvent {
  final bool isFullScreen;

  const ToggleFullScreenEvent(this.isFullScreen);

  @override
  List<Object> get props => [isFullScreen];
}
