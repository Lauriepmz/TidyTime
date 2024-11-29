import 'package:tidytime/utils/all_imports.dart';

// Mapping rooms to their corresponding icons (PNG assets)
Map<String, String> roomIcons = {
  'Attic': 'assets/images/rooms/attic.png',
  'Basement': 'assets/images/rooms/basement.png',
  'Bathroom': 'assets/images/rooms/bathroom.png',
  'Bedroom': 'assets/images/rooms/bedroom.png',
  "Children's Bedroom": 'assets/images/rooms/childrens-bedroom.png',
  'Closet': 'assets/images/rooms/Closet.png',
  'Corridor': 'assets/images/rooms/corridor.png',
  'Dining Room': 'assets/images/rooms/dining-room.png',
  'Entire Home': 'assets/images/rooms/entire-home.png',
  'Entryway': 'assets/images/rooms/entryway.png',
  'Garage': 'assets/images/rooms/garage.png',
  'Guest Bedroom': 'assets/images/rooms/guest-bedroom.png',
  'Home Gym': 'assets/images/rooms/home-gym.png',
  'Home Office': 'assets/images/rooms/home-office.png',
  'Kitchen': 'assets/images/rooms/kitchen.png',
  'Laundry Room': 'assets/images/rooms/laundry-room.png',
  'Living Room': 'assets/images/rooms/living-room.png',
  'Master Bedroom': 'assets/images/rooms/master-bedroom.png',
  'Nursery': 'assets/images/rooms/nursery.png',
  'Pantry': 'assets/images/rooms/pantry.png',
  'Play Room': 'assets/images/rooms/play-room.png',
  'Storage Room': 'assets/images/rooms/storage-room.png',
  'Terrace Patio': 'assets/images/rooms/terrace-patio.png',
};

// Function to get the icon path dynamically based on the room key
String _getRoomIcon(String roomKey) {
  return roomIcons[roomKey] ?? 'assets/images/rooms/default.png'; // Use default icon if not found
}

class RoomSelectionBase extends StatefulWidget {
  final bool allowMultipleSelection;
  final List<String> initialSelectedRooms;
  final List<String> roomChoices;
  final ValueChanged<List<String>> onRoomsSelected;
  final TextEditingController customRoomController;
  final ValueChanged<String> onCustomRoomSubmitted;

  const RoomSelectionBase({
    super.key,
    required this.allowMultipleSelection,
    required this.initialSelectedRooms,
    required this.roomChoices,
    required this.onRoomsSelected,
    required this.customRoomController,
    required this.onCustomRoomSubmitted,
  });

  @override
  RoomSelectionBaseState createState() => RoomSelectionBaseState();
}

class RoomSelectionBaseState extends State<RoomSelectionBase> {
  late List<Map<String, String>> _allRooms;
  late List<String> _selectedRooms;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredRooms = [];
  List<String> _customRooms = [];

  @override
  void initState() {
    super.initState();
    _selectedRooms = List<String>.from(widget.initialSelectedRooms);
    _filteredRooms = [];
    _loadCustomRooms();
    _searchController.addListener(_filterRooms);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ensure roomChoices is updated with localized names when dependencies change
    _allRooms = roomChoices(context);
    _updateFilteredRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredRooms() {
    setState(() {
      _filteredRooms = [
        ..._allRooms,
        ..._customRooms.map((room) => {'key': room, 'name': room}),
      ]..sort((a, b) => a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()));
    });
  }

  void _filterRooms() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRooms = [
        ..._allRooms,
        ..._customRooms.map((room) => {'key': room, 'name': room}),
      ]
          .where((room) => room['name']!.toLowerCase().contains(query))
          .toList()
        ..sort((a, b) => a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()));
    });
  }

  Future<void> _loadCustomRooms() async {
    try {
      List<String> customRooms = await RoomManager.getCustomRooms();
      setState(() {
        _customRooms = customRooms
            .where((room) => !_allRooms.any((r) => r['key'] == room))
            .toList();
        _updateFilteredRooms();
      });
    } catch (e) {
      print('Error loading custom rooms: $e');
    }
  }

  void _handleRoomSelected(String roomKey) {
    setState(() {
      if (widget.allowMultipleSelection) {
        if (!_selectedRooms.contains(roomKey)) {
          _selectedRooms.add(roomKey);
        }
      } else {
        _selectedRooms = [roomKey];
      }
      widget.onRoomsSelected(_selectedRooms);
    });
  }

  void _handleRoomDeselected(String roomKey) {
    setState(() {
      if (widget.allowMultipleSelection) {
        _selectedRooms.remove(roomKey);
      } else {
        _selectedRooms = [];
      }
      widget.onRoomsSelected(_selectedRooms);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)?.searchRooms ?? 'Search Rooms',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () => _showAddRoomDialog(context),
                  child: ButtonStyles.gradientContainer(
                    pattern: GradientPattern.patternThree,
                    borderRadius: 15,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add, size: 32, color: Colors.black),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)?.addCustomRoom ?? 'Add Custom Room',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ..._filteredRooms.map((room) {
                final isSelected = _selectedRooms.contains(room['key']);
                final roomIcon = _getRoomIcon(room['key']!);
                return _buildRoomTile(room, roomIcon, isSelected);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomTile(Map<String, String> room, String roomIcon, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          if (isSelected) {
            _handleRoomDeselected(room['key']!);
          } else {
            _handleRoomSelected(room['key']!);
          }
        },
        child: ButtonStyles.gradientContainer(
          pattern: isSelected
              ? GradientPattern.patternThree
              : GradientPattern.patternOne,
          borderRadius: 15,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  roomIcon,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                room['name']!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF9C27B0) : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter custom room name'),
          content: TextField(
            controller: widget.customRoomController,
            decoration: const InputDecoration(labelText: 'Room Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newRoom = widget.customRoomController.text.trim();
                if (newRoom.isNotEmpty) {
                  await RoomManager.addCustomRoom(newRoom);
                  setState(() {
                    _customRooms.add(newRoom);
                    _updateFilteredRooms();
                  });
                  widget.onCustomRoomSubmitted(newRoom);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

