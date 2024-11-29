import 'package:tidytime/utils/all_imports.dart';

class RoomListWidget extends StatelessWidget {
  final List<String> rooms;
  final VoidCallback onRefresh;

  const RoomListWidget({super.key, required this.rooms, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final roomKey = rooms[index]; // La clé de la pièce
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskListPage(room: roomKey),
              ),
            ).then((_) => onRefresh());
          },
          child: _buildRoomTile(context, roomKey), // Passez `context` pour la traduction
        );
      },
    );
  }

  Widget _buildRoomTile(BuildContext context, String roomKey) {
    String? roomIcon = roomIcons[roomKey];
    String translatedRoomName = getTranslatedRoomName(context, roomKey); // Traduisez le nom

    return ButtonStyles.gradientContainer(
      borderRadius: 10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          roomIcon != null
              ? Flexible(
            child: Image.asset(
              roomIcon,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          )
              : const SizedBox(),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              translatedRoomName, // Affichez le nom traduit
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
