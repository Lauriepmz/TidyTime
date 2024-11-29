import 'package:hive/hive.dart';

part 'temporary_selected_tasks_model.g.dart';

@HiveType(typeId: 4)
class SelectedTask extends HiveObject {
  @HiveField(0)
  String taskNameSelected;

  @HiveField(1)
  String taskRoomSelected;

  @HiveField(2)
  String taskTypeSelected;

  @HiveField(3)
  String repeatUnitSelected;

  @HiveField(4)
  int repeatValueSelected;

  SelectedTask({
    required this.taskNameSelected,
    required this.taskRoomSelected,
    required this.taskTypeSelected,
    required this.repeatUnitSelected,
    required this.repeatValueSelected,
  });
}
