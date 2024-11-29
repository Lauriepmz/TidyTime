import 'package:tidytime/utils/all_imports.dart';

class TaskPlanningBloc extends Bloc<TaskPlanningEvent, TaskPlanningState> {
  final HiveBoxManager hiveBoxManager = HiveBoxManager.instance;
  late final TimeProportionConverter timeProportionConverter;

  final Map<String, int> questionMapping = {
    'By frequency': 1, // Q1
    'By task type': 2, // Q2
    'By room': 3       // Q3
  };

  Map<int, List<String>> temporaryGroupedRooms = {};

  TaskPlanningBloc() : super(TaskPlanningInitial()) {
    on<StartTaskPlanning>(_onStartTaskPlanning);
    on<CompleteTaskPlanning>(_onCompleteTaskPlanning);
    on<SaveSelectedRooms>(_onSaveSelectedRooms);
    on<SaveSelectedTasks>(_onSaveSelectedTasks);
    on<SaveTaskTemporaryChanges>(_onSaveTaskTemporaryChanges);
    on<SaveTimeAllocation>(_onSaveTimeAllocation);
    on<SavePreferenceRanking>(_onSavePreferenceRanking);
    on<DeleteSelectedTask>(_onDeleteSelectedTask);
    on<SaveSingleChoiceAnswer>(_onSaveSingleChoiceAnswer);
    on<SaveGroupedRoomsTemporarily>((event, emit) {
      temporaryGroupedRooms = event.groupedRooms;
      print('Grouped rooms temporarily saved: $temporaryGroupedRooms');
    });
    on<CompleteTaskPlanningFinalization>((event, emit) async {
      try {
        await hiveBoxManager.clearAndCloseAllBoxes();
        temporaryGroupedRooms.clear();
        emit(TaskPlanningCompleted());
        print("Task planning finalized.");
      } catch (e) {
        emit(TaskPlanningError('Error during finalization: $e'));
      }
    });
    on<GetTasksForRoom>((event, emit) {
      try {
        final tasks = getTasksForRoom(event.roomKey); // Use roomKey directly
        print('[DEBUG] Retrieved tasks for room with key "${event.roomKey}": $tasks');
        emit(TasksLoadedState(tasks: tasks));
      } catch (e) {
        print('Error retrieving tasks for room "${event.roomKey}": $e');
        emit(TaskPlanningError('Failed to retrieve tasks for room ${event.roomKey}'));
      }
    });
  }

  bool isConverterInitialized = false; // Add this flag to track initialization

  Future<void> ensureBoxesInitialized() async {
    if (!hiveBoxManager.areBoxesInitialized()) {
      await hiveBoxManager.initializeBoxes();
    }

    // Confirm all required boxes are open before proceeding
    while (!Hive.isBoxOpen('tempTimeProportionBox') ||
        !Hive.isBoxOpen('tempTimeAllocationBox') ||
        !Hive.isBoxOpen('tempRoomSelectedBox') ||
        !Hive.isBoxOpen('SelectedTasks') ||
        !Hive.isBoxOpen('QuizzResultsBox')) { // Ensure QuizzResultsBox is included
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Initialize converter only once, after confirming all boxes are open
    if (!isConverterInitialized) {
      timeProportionConverter = TimeProportionConverter(
        timeProportionBox: hiveBoxManager.getBox<TimeProportion>('tempTimeProportionBox'),
        timeAllocationBox: hiveBoxManager.getBox<TimeAllocation>('tempTimeAllocationBox'),
      );
      isConverterInitialized = true;
      print("TimeProportionConverter initialized successfully.");
    }
  }

  Future<void> _onStartTaskPlanning(StartTaskPlanning event, Emitter<TaskPlanningState> emit) async {
    emit(TaskPlanningProgress(0.0));
    print("Starting Task Planning");

    try {
      await ensureBoxesInitialized();
      emit(TaskPlanningLoaded());
      print("Task Planning Loaded");
    } catch (e) {
      print('Error initializing Hive boxes in _onStartTaskPlanning: $e');
      emit(TaskPlanningError('Failed to initialize Hive boxes'));
    }
  }

  Future<void> _onCompleteTaskPlanning(
      CompleteTaskPlanning event, Emitter<TaskPlanningState> emit) async {
    try {
      print("Starting task planning...");

      // Steps 1 to 6: Execute the planning algorithm
      Map<String, dynamic> initializationData = await initializeGroupTimeProportions();
      Map<String, Map<String, dynamic>> groupTimeProportions = initializationData["groupTimeProportions"];
      List<Map<String, dynamic>> taskWeights = initializationData["taskWeights"];
      Map<int, List<String>> groupedRooms = temporaryGroupedRooms;

      await distributeTasksByRoomGroups(groupTimeProportions, taskWeights, groupedRooms);
      await applyUserPreferencesToTaskDistribution(groupTimeProportions, taskWeights);

      TaskScheduler scheduler = TaskScheduler();
      Map<int, DateTime> tempStartDates = await scheduler.calculateAndDistributeDueDates(groupTimeProportions);
      await logTasksAndUpdateStartDates(taskWeights, tempStartDates, DatabaseHelper.instance, TaskDetailsFetcher());

      // Emit the final completion state instead of the transitional state
      emit(TaskPlanningCompleted());
      print("Task planning completed and TaskPlanningCompleted state emitted.");
    } catch (e) {
      emit(TaskPlanningError('Failed to complete task planning: $e'));
    }
  }

  Future<void> _onSaveSelectedRooms(SaveSelectedRooms event, Emitter<TaskPlanningState> emit) async {
    final box = hiveBoxManager.getBox<RoomSelected>('tempRoomSelectedBox');
    await box.clear();

    for (var room in event.selectedRooms) {
      final roomKey = room['key'] ?? 'unknown_key'; // Fallback to 'unknown_key'
      final roomName = room['name'] ?? 'Unknown Room'; // Fallback to 'Unknown Room'

      print('[DEBUG] Saving room: key="$roomKey", name="$roomName"');
      await box.add(RoomSelected(roomName: roomName, roomKey: roomKey));
    }
  }

  List<String> getSelectedRooms() {
    final box = hiveBoxManager.getBox<RoomSelected>('tempRoomSelectedBox');
    final roomKeys = box.values.map((room) => room.roomKey).toList();

    print('[DEBUG] Raw room keys retrieved from Hive: $roomKeys');
    return roomKeys;
  }

  List<Map<String, dynamic>> getTasksForRoom(String roomKey) {
    final box = hiveBoxManager.getBox<SelectedTask>('SelectedTasks');

    // Log all tasks in the box for debugging
    print('[DEBUG] All tasks in SelectedTasks box: ${box.values.toList()}');

    print('[DEBUG] Accessing SelectedTasks box for room key: "$roomKey"');
    final tasksForRoom = box.values
        .where((task) => task.taskRoomSelected == roomKey)
        .map((task) => {
      'taskName': task.taskNameSelected,
      'taskType': task.taskTypeSelected,
      'repeatUnit': task.repeatUnitSelected,
      'repeatValue': task.repeatValueSelected,
      'rooms': [task.taskRoomSelected],
    })
        .toList();

    print('[DEBUG] Total tasks for room "$roomKey": ${tasksForRoom.length}');
    print('[DEBUG] Loaded tasks for room "$roomKey": $tasksForRoom');

    return tasksForRoom;
  }

  Future<void> _onSaveTaskTemporaryChanges(
      SaveTaskTemporaryChanges event, Emitter<TaskPlanningState> emit) async {
    final box = hiveBoxManager.getBox('TemporaryTaskModifications');

    await box.put(event.modifiedDetails['taskName'], event.modifiedDetails);
    print('Temporary task changes saved: ${event.modifiedDetails}');
  }

  Future<void> _onSaveSelectedTasks(SaveSelectedTasks event, Emitter<TaskPlanningState> emit) async {
    final box = hiveBoxManager.getBox<SelectedTask>('SelectedTasks');

    try {
      // Delete existing tasks for the room before saving
      final existingTasks = box.values.where((task) => task.taskRoomSelected == event.roomKey).toList();

      for (var existingTask in existingTasks) {
        final taskKey = existingTask.key as int?;
        if (taskKey != null) {
          await box.delete(taskKey);
          print('Deleted task for room "${event.roomKey}": ${existingTask.taskNameSelected}');
        }
      }

      // Save new tasks
      for (var task in event.selectedTasks) {
        final newTask = SelectedTask(
          taskNameSelected: task['taskNameSelected'] ?? 'Unnamed Task',
          taskRoomSelected: event.roomKey, // Use roomKey
          taskTypeSelected: task['taskTypeSelected'] ?? 'General',
          repeatUnitSelected: task['repeatUnitSelected'] ?? 'days',
          repeatValueSelected: task['repeatValueSelected'] ?? 1,
        );

        await box.add(newTask);
        print('Saved task for room "${event.roomKey}": ${newTask.taskNameSelected}');
      }

      print('All tasks saved successfully for room ${event.roomKey}.');
    } catch (e) {
      print('Error saving tasks: $e');
      emit(TaskPlanningError('Failed to save tasks for room ${event.roomKey}'));
    }
  }

  Future<void> _onDeleteSelectedTask(DeleteSelectedTask event, Emitter<TaskPlanningState> emit) async {
    final box = hiveBoxManager.getBox<SelectedTask>('SelectedTasks');

    try {
      // Find the task that matches both taskName and roomName criteria
      final taskToDelete = box.values.firstWhere(
            (task) => task.taskNameSelected == event.taskName && task.taskRoomSelected == event.roomName,
      );

      // Check if the task exists and delete by its unique key
      final taskKey = taskToDelete.key as int?;
      if (taskKey != null) {
        await box.delete(taskKey);
        print('Task deleted: ${event.taskName} from ${event.roomName}');
      } else {
        print('No matching task found to delete.');
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<int> getTaskCountForRoom(String roomKey) async {
    final selectedTasksBox = hiveBoxManager.getBox<SelectedTask>('SelectedTasks');
    return selectedTasksBox.values.where((task) => task.taskRoomSelected == roomKey).length;
  }


  Future<void> _onSaveTimeAllocation(
      SaveTimeAllocation event, Emitter<TaskPlanningState> emit) async {
    final timeAllocationBox = hiveBoxManager.getBox<TimeAllocation>('tempTimeAllocationBox');
    final timeProportionBox = hiveBoxManager.getBox<TimeProportion>('tempTimeProportionBox');

    try {
      double totalTime = event.dailyTimeAllocation.values.fold(0, (sum, value) => sum + value);

      for (var entry in event.dailyTimeAllocation.entries) {
        var timeAllocation = TimeAllocation(day: entry.key, allocatedTime: entry.value);
        await timeAllocationBox.put(entry.key, timeAllocation);

        double proportion = totalTime > 0 ? entry.value / totalTime : 0;

        var timeProportion = TimeProportion(day: entry.key, allocatedProportion: proportion);
        await timeProportionBox.put(entry.key, timeProportion);

        print(
            'Saved in tempTimeAllocationBox: Day = ${entry.key}, Allocated Time = ${entry.value} hours');
        print(
            'Saved in tempTimeProportionBox: Day = ${entry.key}, Proportion = ${proportion.toStringAsFixed(2)}');
      }

      if (event.dailyTimeAllocation.values.any((time) => time > 0)) {
        await timeProportionBox.put(
            'total', TimeProportion(day: 'total', allocatedProportion: 1.0));
        print('Total proportion saved as 1.0 in tempTimeProportionBox');
      } else {
        await timeProportionBox.delete('total');
        print('Total proportion entry deleted from tempTimeProportionBox');
      }

      print('Time allocation and proportions updated successfully.');

    } catch (e) {
      print('Error saving time allocations: $e');
      emit(TaskPlanningError('Failed to save time allocation'));
    }
  }

  Future<void> _onSavePreferenceRanking(
      SavePreferenceRanking event, Emitter<TaskPlanningState> emit) async {
    try {
      final answersBox = hiveBoxManager.getBox<QuizzResults>('QuizzResultsBox');

      print("Ranked preferences received: ${event.rankedPreferences}");

      for (var entry in event.rankedPreferences.entries) {
        final questionNumber = entry.key; // Correct question number
        final rank = entry.value;

        print('Saving ranking preference - Question: $questionNumber, Rank: $rank');

        await answersBox.add(
          QuizzResults(
            question: questionNumber,
            rank: rank,
            answer: 0, // Placeholder for now, updated later if necessary
          ),
        );
      }
    } catch (e) {
      print('Error saving ranking preferences: $e');
      emit(TaskPlanningError('Failed to save ranking preferences.'));
    }
  }


  Future<void> _onSaveSingleChoiceAnswer(
      SaveSingleChoiceAnswer event, Emitter<TaskPlanningState> emit) async {
    try {
      final answersBox = hiveBoxManager.getBox<QuizzResults>('QuizzResultsBox');

      print("Saving single choice answer: Question=${event.questionNumber}, Rank=${event.rank}, Answer=${event.answer}");

      final existingEntryIndex = answersBox.values.toList().indexWhere(
            (entry) => entry.question == event.questionNumber,
      );

      if (existingEntryIndex != -1) {
        await answersBox.putAt(
          existingEntryIndex,
          QuizzResults(
            question: event.questionNumber,
            rank: event.rank,
            answer: event.answer,
          ),
        );
        print('Updated single choice answer in Hive.');
      } else {
        await answersBox.add(
          QuizzResults(
            question: event.questionNumber,
            rank: event.rank,
            answer: event.answer,
          ),
        );
        print('Saved single choice answer in Hive.');
      }
    } catch (e) {
      print('Error saving single choice answer: $e');
      emit(TaskPlanningError('Failed to save single choice answer.'));
    }
  }
}
