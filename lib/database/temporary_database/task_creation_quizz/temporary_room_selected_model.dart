import 'package:tidytime/utils/all_imports.dart';

part 'temporary_room_selected_model.g.dart';

@HiveType(typeId: 3) // Unique typeId
class RoomSelected extends HiveObject {
  @HiveField(0)
  final String roomName;

  @HiveField(1)
  final String roomKey;

  RoomSelected({
    required this.roomName,
    required this.roomKey,
  });

  // Factory to handle null fields and provide defaults
  factory RoomSelected.fromHive(Map<dynamic, dynamic> fields) {
    return RoomSelected(
      roomName: fields[0] as String? ?? 'Unknown Room',
      roomKey: fields[1] as String? ?? 'unknown_key',
    );
  }

  Map<String, dynamic> toMap() {
    return {'roomName': roomName, 'roomKey': roomKey};
  }
}
