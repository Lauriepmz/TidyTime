import 'package:tidytime/utils/all_imports.dart';

class RoomManager {
  static Future<List<String>> getCustomRooms() async {
    try {
      final rooms = await DatabaseHelper.instance.getCustomRooms();
      print('Loaded custom rooms: $rooms'); // Debug log
      return rooms;
    } catch (e) {
      print('Failed to load custom rooms: $e'); // Debug log
      throw Exception('Failed to load custom rooms: $e');
    }
  }

  static Future<void> addCustomRoom(String newRoom) async {
    if (newRoom.isNotEmpty) {
      try {
        // Vérifiez si la pièce existe déjà
        final existingRooms = await DatabaseHelper.instance.getCustomRooms();
        if (existingRooms.contains(newRoom)) {
          print('Room "$newRoom" already exists.');
          return; // Ne pas insérer si la pièce existe déjà
        }

        // Insérez la nouvelle pièce si elle n'existe pas
        await DatabaseHelper.instance.insertCustomRoom(newRoom);
        print('Custom room added: $newRoom');
      } catch (e) {
        print('Failed to add custom room: $e');
        throw Exception('Failed to add custom room: $e');
      }
    }
  }
}

