import 'package:tidytime/utils/all_imports.dart';

class RoomSelectedTaskSelection extends StatelessWidget {
  final VoidCallback onTaskSelectionComplete;

  const RoomSelectedTaskSelection({
    Key? key,
    required this.onTaskSelectionComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Step 2: Click on a room to start selecting your tasks.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<TaskPlanningBloc, TaskPlanningState>(
                builder: (context, state) {
                  final bloc = context.read<TaskPlanningBloc>();
                  final selectedRoomKeys = bloc.getSelectedRooms();

                  // Log room keys and translations
                  print('[DEBUG] Room keys retrieved: $selectedRoomKeys');
                  final translatedRoomNames = selectedRoomKeys
                      .map((key) => getTranslatedRoomName(context, key))
                      .toList();
                  print('[DEBUG] Translated room names: $translatedRoomNames');

                  if (selectedRoomKeys.isEmpty) {
                    return const Center(child: Text('No rooms selected.'));
                  }

                  return ListView.builder(
                    itemCount: selectedRoomKeys.length,
                    itemBuilder: (context, index) {
                      final roomKey = selectedRoomKeys[index];
                      final roomName = getTranslatedRoomName(context, roomKey); // Use for display

                      print('[DEBUG] Rendering room: key="$roomKey", name="$roomName"');

                      return FutureBuilder<int>(
                        future: _getTaskCountForRoom(context, roomKey),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              title: Text(roomName, style: const TextStyle(fontSize: 16)),
                              trailing: const CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            print('[ERROR] Error loading task count for room "$roomKey": ${snapshot.error}');
                            return ListTile(
                              title: Text(roomName, style: const TextStyle(fontSize: 16)),
                              trailing: const Text('Error'),
                            );
                          } else {
                            final taskCount = snapshot.data ?? 0;
                            print('[DEBUG] Room "$roomKey" has $taskCount tasks');

                            return ListTile(
                              title: Text(roomName, style: const TextStyle(fontSize: 16)),
                              trailing: Text('$taskCount tasks'),
                              onTap: () async {
                                print('[DEBUG] Navigating to RoomTaskSelectionPage for room "$roomKey"');
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RoomTaskSelectionPage(
                                      roomKey: roomKey, // Pass roomKey for filtering tasks
                                      roomName: roomName, // Pass translated roomName for display
                                      onSelectionConfirmed: onTaskSelectionComplete,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  print('[DEBUG] Tasks updated for room "$roomKey". Refreshing...');
                                  onTaskSelectionComplete();
                                }
                              },
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _getTaskCountForRoom(BuildContext context, String roomKey) async {
    final bloc = context.read<TaskPlanningBloc>();
    final taskCount = await bloc.getTaskCountForRoom(roomKey);
    print('[DEBUG] Retrieved task count for room "$roomKey": $taskCount');
    return taskCount;
  }
}
