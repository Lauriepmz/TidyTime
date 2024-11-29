import 'package:tidytime/utils/all_imports.dart';

class RoomSelector extends StatefulWidget {
  final String? selectedRoom;
  final List<Map<String, String>> roomChoices; // Accepts key-name pairs for translated rooms
  final ValueChanged<String?> onRoomSelected;
  final TextEditingController customRoomController;
  final ValueChanged<String> onCustomRoomSubmitted;

  const RoomSelector({
    super.key,
    required this.selectedRoom,
    required this.roomChoices,
    required this.onRoomSelected,
    required this.customRoomController,
    required this.onCustomRoomSubmitted,
  });

  @override
  State<RoomSelector> createState() => _RoomSelectorState();
}

class _RoomSelectorState extends State<RoomSelector> {
  late List<Map<String, String>> _filteredRooms;
  late List<String> _customRooms; // Custom rooms are plain strings

  @override
  void initState() {
    super.initState();
    _filteredRooms = widget.roomChoices; // Initialize with predefined rooms
    print('[DEBUG] Initial Filtered Rooms: $_filteredRooms');
    _customRooms = [];
    _loadCustomRooms(); // Load custom rooms if any
  }

  Future<void> _loadCustomRooms() async {
    try {
      List<String> customRooms = await RoomManager.getCustomRooms();
      setState(() {
        _customRooms = customRooms
            .where((room) => !_filteredRooms.any((filtered) => filtered['name'] == room))
            .toList(); // Avoid duplicates
        _updateFilteredRooms(); // Combine predefined and custom rooms
      });
    } catch (e) {
      print('Error loading custom rooms: $e');
    }
  }

  void _updateFilteredRooms() {
    setState(() {
      _filteredRooms = [
        ...widget.roomChoices, // Predefined rooms
        ..._customRooms.map((room) => {'key': room, 'name': room}), // Custom rooms
      ];
      print('[DEBUG] Updated Filtered Rooms: $_filteredRooms');
    });
  }



  @override
  Widget build(BuildContext context) {
    return RoomSelectionBase(
      allowMultipleSelection: false,
      initialSelectedRooms: widget.selectedRoom != null ? [widget.selectedRoom!] : [],
      roomChoices: _filteredRooms.map((room) => room['name']!).toList(), // Display translated names
      onRoomsSelected: (rooms) {
        // Récupérer le nom sélectionné dans la langue choisie
        final selectedName = rooms.isNotEmpty ? rooms.first : null;

        print('[DEBUG] Selected Room Name: $selectedName');

        // Aucune recherche de `key` ici, utilisez uniquement `name`
        widget.onRoomSelected(selectedName); // Retourner le nom traduit directement
      },
      customRoomController: widget.customRoomController,
      onCustomRoomSubmitted: (String newRoom) {
        _addCustomRoom(newRoom);
        widget.onCustomRoomSubmitted(newRoom);
      },
    );
  }

  void _addCustomRoom(String newRoom) {
    if (newRoom.isNotEmpty) {
      _customRooms.add(newRoom);
      _updateFilteredRooms();
    }
  }
}
