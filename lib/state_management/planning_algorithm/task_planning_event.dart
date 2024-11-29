import 'package:tidytime/utils/all_imports.dart';

abstract class TaskPlanningEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Event to start task planning (opens the temporary Hive box)
class StartTaskPlanning extends TaskPlanningEvent {}

// Event to complete task planning (closes the temporary Hive box)
class CompleteTaskPlanning extends TaskPlanningEvent {}

// Event to indicate the progress of the algorithm
class UpdateTaskProgress extends TaskPlanningEvent {
  final double progress; // Progress in percentage (e.g., 0.0 to 1.0)

  UpdateTaskProgress(this.progress);

  @override
  List<Object> get props => [progress];
}

class ChangePage extends TaskPlanningEvent {
  final int pageIndex;

  ChangePage(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

class SaveSelectedRooms extends TaskPlanningEvent {
  final List<Map<String, String>> selectedRooms; // Includes both roomKey and roomName

  SaveSelectedRooms(this.selectedRooms);

  @override
  List<Object> get props => [selectedRooms];
}


// Event to save temporary task changes
class SaveTaskTemporaryChanges extends TaskPlanningEvent {
  final Map<String, dynamic> modifiedDetails;

  SaveTaskTemporaryChanges(this.modifiedDetails);

  @override
  List<Object> get props => [modifiedDetails];
}

class SaveTimeAllocation extends TaskPlanningEvent {
  final Map<String, double> dailyTimeAllocation;

  SaveTimeAllocation(this.dailyTimeAllocation);

  @override
  List<Object> get props => [dailyTimeAllocation];
}

class SavePreferenceRanking extends TaskPlanningEvent {
  final Map<int, int> rankedPreferences;

  SavePreferenceRanking(this.rankedPreferences);
}

// Event to save selected tasks for a specific room
class SaveSelectedTasks extends TaskPlanningEvent {
  final String roomKey; // Use roomKey instead of roomName
  final List<Map<String, dynamic>> selectedTasks;

  SaveSelectedTasks(this.roomKey, this.selectedTasks);

  @override
  List<Object> get props => [roomKey, selectedTasks];
}

// New event for saving a single-choice answer in the quiz
class SaveSingleChoiceAnswer extends TaskPlanningEvent {
  final int questionNumber;
  final int rank;
  final int answer;

  SaveSingleChoiceAnswer(this.questionNumber, this.rank, this.answer);

  @override
  List<Object> get props => [questionNumber, answer];
}

class DeleteSelectedTask extends TaskPlanningEvent {
  final String taskName;
  final String roomName;

  DeleteSelectedTask(this.taskName, this.roomName);
}

// Event to save grouped rooms temporarily
class SaveGroupedRoomsTemporarily extends TaskPlanningEvent {
  final Map<int, List<String>> groupedRooms;

  SaveGroupedRoomsTemporarily(this.groupedRooms);
}

class CompleteTaskPlanningFinalization extends TaskPlanningEvent {}

// Event to get tasks for a room based on its translated key
class GetTasksForRoom extends TaskPlanningEvent {
  final String roomKey; // Use the translated roomKey instead of roomName

  GetTasksForRoom(this.roomKey);

  @override
  List<Object> get props => [roomKey];
}
