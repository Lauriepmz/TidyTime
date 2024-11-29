import 'package:tidytime/utils/all_imports.dart';

List<Map<String, dynamic>> filterPredefinedTasks(
    BuildContext context, {
      required String selectedRoom,
      required String selectedTaskType,
    }) {

  // Obtain the room choices (keys and translated names)
  final roomChoicesList = roomChoices(context);

  // Find the key of the selected room
  String? selectedRoomKey;
  if (selectedRoom != 'All') {
    selectedRoomKey = roomChoicesList.firstWhere(
          (choice) => choice['key'] == selectedRoom, // Ensure this checks against the roomKey
      orElse: () => {'key': ""},
    )['key'];
  }

  // Log debug information for the filtering process
  print('[DEBUG] Filtering tasks for roomKey="$selectedRoomKey" and type="$selectedTaskType"');

  return predefinedTasks.where((task) {
    // Check if the room matches
    List<String> taskRooms = task['rooms'] as List<String>;
    bool isRoomValid = selectedRoom == 'All' || (selectedRoomKey != null && taskRooms.contains(selectedRoomKey));

    // Check if the task type matches
    String taskType = task['taskType'] as String;
    bool isTypeValid = selectedTaskType == 'All' || taskType.toLowerCase() == selectedTaskType.toLowerCase();

    // Log tasks that fail the filtering criteria
    if (!isRoomValid || !isTypeValid) {
      print('[DEBUG] Task "${task['taskName']}" excluded. Room valid: $isRoomValid, Type valid: $isTypeValid');
    }

    return isRoomValid && isTypeValid;
  }).toList();
}
