import 'package:tidytime/utils/all_imports.dart'; // Adapter les imports si nécessaire

String getTranslatedRoomName(BuildContext context, String roomKey) {
  // Normalize the key to ensure consistent format
  String normalizedKey = roomKey.replaceAll(' ', '').toLowerCase();

  // Search for the matching room choice
  final room = roomChoices(context).firstWhere(
        (choice) {
      final key = choice['key'] ?? ''; // Handle null keys safely
      return key.replaceAll(' ', '').toLowerCase() == normalizedKey;
    },
    orElse: () => {'key': roomKey, 'name': 'Unknown'},
  );

  return room['name'] ?? 'Unknown';
}

String getRoomKey(BuildContext context, String translatedRoomName) {
  print('[DEBUG] Translated Room Name: $translatedRoomName');

  if (translatedRoomName == 'All') {
    return 'All'; // Special case for the "All" room option
  }

  final roomChoicesList = roomChoices(context);
  final room = roomChoicesList.firstWhere(
        (room) => room['name'] == translatedRoomName,
    orElse: () => {'key': 'Unknown'},
  );

  print('[DEBUG] Room Key for Translated Name "$translatedRoomName": ${room['key']}');
  return room['key'] ?? 'Unknown';
}

String translateToDefaultLanguage(BuildContext context, String roomKey) {
  print('[DEBUG] Translating Room Key to Default Language: $roomKey');

  final room = roomChoices(context).firstWhere(
        (element) => element['key'] == roomKey,
    orElse: () => {'key': roomKey, 'name': 'Unknown'},
  );

  print('[DEBUG] Default Language Key for Room "$roomKey": ${room['key']}');
  return room['key'] ?? 'Unknown';
}
