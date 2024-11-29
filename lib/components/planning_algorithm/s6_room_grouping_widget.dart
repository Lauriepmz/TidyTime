import 'package:tidytime/utils/all_imports.dart';

class RoomGroupingWidget extends StatelessWidget {
  final List<String> rooms; // Room keys
  final Map<int, List<String>> groupedRooms; // Groups by room keys
  final Function(int, List<String>) onRoomGroupingUpdated;

  const RoomGroupingWidget({
    Key? key,
    required this.rooms,
    required this.groupedRooms,
    required this.onRoomGroupingUpdated,
  }) : super(key: key);

  void _onRoomDropped(int targetIndex, String roomKey, BuildContext context) {
    print('[DEBUG] Room dropped: $roomKey to group $targetIndex');
    print('[DEBUG] Before drop, groupedRooms: $groupedRooms');

    // Remove room from any other group
    groupedRooms.forEach((_, group) => group.remove(roomKey));
    // Add room to the target group
    groupedRooms[targetIndex] = groupedRooms[targetIndex] ?? [];
    groupedRooms[targetIndex]!.add(roomKey);

    print('[DEBUG] After drop, groupedRooms: $groupedRooms');
    // Notify parent widget of the updated group
    onRoomGroupingUpdated(targetIndex, groupedRooms[targetIndex]!);
  }

  void _onRemoveRoomFromGroup(int groupIndex, String roomKey) {
    print('[DEBUG] Removing room $roomKey from group $groupIndex');
    print('[DEBUG] Before removal, groupedRooms: $groupedRooms');

    // Remove room from the current group
    groupedRooms[groupIndex]?.remove(roomKey);

    print('[DEBUG] After removal, groupedRooms: $groupedRooms');
    onRoomGroupingUpdated(groupIndex, groupedRooms[groupIndex] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] Building RoomGroupingWidget');
    print('[DEBUG] Initial rooms: $rooms');
    print('[DEBUG] Initial groupedRooms: $groupedRooms');

    // Translate room keys for display
    final translatedRooms = rooms.map((roomKey) {
      final translatedName = getTranslatedRoomName(context, roomKey);
      print('[DEBUG] Translated roomKey "$roomKey" to "$translatedName"');
      return translatedName;
    }).toList();

    print('[DEBUG] Translated rooms: $translatedRooms');

    // Rooms not yet grouped
    final availableRooms = rooms.where((roomKey) =>
        groupedRooms.values.every((group) => !group.contains(roomKey))).toList();
    print('[DEBUG] Available rooms for grouping: $availableRooms');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Drag and drop rooms to create groups for a cleaning session:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(groupedRooms.length, (index) {
              return Expanded(
                child: DragTarget<String>(
                  onAcceptWithDetails: (details) {
                    print('[DEBUG] DragTarget accepted roomKey: ${details.data}');
                    _onRoomDropped(index, details.data, context);
                  },
                  builder: (context, candidateData, rejectedData) {
                    print('[DEBUG] Building DragTarget for group $index');
                    return Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 200,
                      child: Column(
                        children: [
                          Text('Group ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: ListView(
                              children: groupedRooms[index]!
                                  .map((roomKey) {
                                final translatedRoomName = getTranslatedRoomName(context, roomKey);
                                print('[DEBUG] Room in group $index: $roomKey (translated: $translatedRoomName)');
                                return GestureDetector(
                                  onTap: () => _onRemoveRoomFromGroup(index, roomKey),
                                  child: _buildRoomTile(translatedRoomName),
                                );
                              })
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Rooms:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: availableRooms.map((roomKey) {
            final translatedRoomName = getTranslatedRoomName(context, roomKey);
            print('[DEBUG] Available roomKey "$roomKey" (translated: $translatedRoomName)');
            return Draggable<String>(
              data: roomKey,
              child: _buildRoomTile(translatedRoomName),
              feedback: Material(child: _buildRoomTile(translatedRoomName, isDragging: true)),
              childWhenDragging: _buildRoomTile(translatedRoomName, isDragging: true),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRoomTile(String roomName, {bool isDragging = false}) {
    print('[DEBUG] Building room tile for "$roomName", isDragging: $isDragging');
    return Container(
      width: 100,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isDragging ? Colors.blue.withOpacity(0.5) : Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Center(
        child: Text(
          roomName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
