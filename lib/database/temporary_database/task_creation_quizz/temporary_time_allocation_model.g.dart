// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temporary_time_allocation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeAllocationAdapter extends TypeAdapter<TimeAllocation> {
  @override
  final int typeId = 2;

  @override
  TimeAllocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeAllocation(
      day: fields[0] as String,
      allocatedTime: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TimeAllocation obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.allocatedTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeAllocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
