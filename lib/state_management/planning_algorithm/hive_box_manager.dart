import 'package:tidytime/utils/all_imports.dart';

class HiveBoxManager {
  HiveBoxManager._internal();
  static final HiveBoxManager instance = HiveBoxManager._internal();

  final Map<String, Box> _openedBoxes = {};

  Future<void> initializeBoxes() async {
    try {
      _openedBoxes['tempTimeProportionBox'] = await Hive.openBox<TimeProportion>('tempTimeProportionBox');
      print('Opened tempTimeProportionBox');
      _openedBoxes['tempTimeAllocationBox'] = await Hive.openBox<TimeAllocation>('tempTimeAllocationBox');
      print('Opened tempTimeAllocationBox');
      _openedBoxes['tempRoomSelectedBox'] = await Hive.openBox<RoomSelected>('tempRoomSelectedBox');
      print('Opened tempRoomSelectedBox');
      _openedBoxes['SelectedTasks'] = await Hive.openBox<SelectedTask>('SelectedTasks');
      print('Opened SelectedTasks');
      _openedBoxes['QuizzResultsBox'] = await Hive.openBox<QuizzResults>('QuizzResultsBox'); // Add QuizzResultsBox
      print('Opened QuizzResultsBox'); // Log for tracking
    } catch (e) {
      print("Error opening Hive boxes: $e");
      throw Exception("Failed to initialize Hive boxes properly.");
    }
  }

  bool areBoxesInitialized() {
    return _openedBoxes.isNotEmpty && _openedBoxes.values.every((box) => box.isOpen);
  }

  Box<T> getBox<T>(String boxName) {
    if (_openedBoxes.containsKey(boxName) && _openedBoxes[boxName]!.isOpen) {
      print('Accessing box: $boxName');
      return _openedBoxes[boxName] as Box<T>;
    } else {
      throw Exception('Box $boxName is not opened. Ensure initializeBoxes() was called.');
    }
  }

  Future<void> clearAndCloseAllBoxes() async {
    for (var box in _openedBoxes.values) {
      await box.clear();
      await box.close();
    }
    _openedBoxes.clear();
    print("All Hive boxes have been cleared and closed.");
  }
}
