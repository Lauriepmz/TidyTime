// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temporary_selected_tasks_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SelectedTaskAdapter extends TypeAdapter<SelectedTask> {
  @override
  final int typeId = 4;

  @override
  SelectedTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SelectedTask(
      taskNameSelected: fields[0] as String,
      taskRoomSelected: fields[1] as String,
      taskTypeSelected: fields[2] as String,
      repeatUnitSelected: fields[3] as String,
      repeatValueSelected: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SelectedTask obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.taskNameSelected)
      ..writeByte(1)
      ..write(obj.taskRoomSelected)
      ..writeByte(2)
      ..write(obj.taskTypeSelected)
      ..writeByte(3)
      ..write(obj.repeatUnitSelected)
      ..writeByte(4)
      ..write(obj.repeatValueSelected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
