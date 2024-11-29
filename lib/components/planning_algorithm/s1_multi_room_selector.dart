import 'package:tidytime/utils/all_imports.dart';

class MultiRoomSelector extends StatelessWidget {
  final PageController pageController;
  final List<String> initialSelectedRooms;
  final List<String> roomChoices;
  final ValueChanged<List<String>> onRoomsSelected;
  final TextEditingController customRoomController;
  final ValueChanged<String> onCustomRoomSubmitted;

  const MultiRoomSelector({
    super.key,
    required this.pageController,
    required this.initialSelectedRooms,
    required this.roomChoices,
    required this.onRoomsSelected,
    required this.customRoomController,
    required this.onCustomRoomSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return RoomSelectionBase(
      allowMultipleSelection: true,
      initialSelectedRooms: initialSelectedRooms,
      roomChoices: roomChoices,
      onRoomsSelected: onRoomsSelected,
      customRoomController: customRoomController,
      onCustomRoomSubmitted: onCustomRoomSubmitted,
    );
  }
}
