import 'package:tidytime/utils/all_imports.dart';

Future<void> handleTaskSubmission({
  required BuildContext context,
  required TextEditingController taskNameController,
  required String? selectedRoom,
  required List<String> selectedTaskTypes,
  required int repeatValue,
  required String repeatUnit,
  required DateTime startDate,
}) async {
  // Validation des champs obligatoires
  if (selectedRoom == null || taskNameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all required fields')),
    );
    print('[ERROR] Validation failed: Room or task name is empty.');
    return;
  }

  FocusScope.of(context).unfocus();

  try {
    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Validation supplémentaire pour `selectedRoom`
    if (selectedRoom.trim().isEmpty) {
      print('[ERROR] Selected room is invalid (empty key).');
      Navigator.pop(context); // Hide the spinner
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected room is invalid. Please try again.')),
      );
      return;
    }

    // Logs pour débogage
    print('[INFO] Submitting task...');
    print('Task Name: ${taskNameController.text}');
    print('Selected Room: $selectedRoom');
    print('Selected Task Types: $selectedTaskTypes');
    print('Repeat Value: $repeatValue');
    print('Repeat Unit: $repeatUnit');
    print('Start Date: $startDate');

    // Soumission de la tâche
    TaskSubmitService taskSubmitService = TaskSubmitService(TaskService());

    int taskId = await taskSubmitService.submitTask(
      taskName: taskNameController.text,
      selectedRoom: selectedRoom.trim(), // Nettoyer l'identifiant
      selectedTaskTypes: selectedTaskTypes,
      repeatValue: repeatValue,
      repeatUnit: repeatUnit,
      startDate: startDate,
    );

    print('[SUCCESS] Task submitted successfully. Task ID: $taskId');

    // Fermer le spinner
    Navigator.pop(context);

    // Naviguer vers la page de détails de la tâche
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailPage(taskId: taskId)),
    );
  } catch (e) {
    Navigator.pop(context); // Hide the spinner
    print('[ERROR] Task submission failed: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving task: $e')),
    );
  }
}
