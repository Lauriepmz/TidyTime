import 'package:tidytime/utils/all_imports.dart';

class TaskSubmitService {
  final TaskService taskService;

  TaskSubmitService(this.taskService);

  Future<int> submitTask({
    required String taskName,
    required String selectedRoom,
    required List<String> selectedTaskTypes,
    required int repeatValue,
    required String repeatUnit,
    required DateTime startDate,
  }) async {
    // Calculate due dates for the task
    Map<String, DateTime?> dueDates = DateCalculator.calculateTaskCreationDates(startDate: startDate);

    // Create a new Task object
    Task newTask = Task(
      taskName: taskName,
      room: selectedRoom,
      repeatValue: repeatValue,
      repeatUnit: repeatUnit,
      startDate: startDate,
      dueDateLastDone: dueDates['dueDateLastDone'],
      dueDateLastDoneProposed: dueDates['dueDateLastDoneProposed'],
      taskType: selectedTaskTypes.join(', '),
    );

    // Insert the task into the database using TaskService
    return await taskService.addTask(newTask);
  }
}
