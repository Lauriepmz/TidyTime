// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temporary_task_timer_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TemporaryTaskTimerLogAdapter extends TypeAdapter<TemporaryTaskTimerLog> {
  @override
  final int typeId = 0;

  @override
  TemporaryTaskTimerLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemporaryTaskTimerLog(
      taskId: fields[0] as int,
      startTime: fields[1] as int,
      endTime: fields[2] as int,
      elapsedTime: fields[3] as int,
      status: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TemporaryTaskTimerLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.taskId)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.elapsedTime)
      ..writeByte(4)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemporaryTaskTimerLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
