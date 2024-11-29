// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temporary_time_proportion_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeProportionAdapter extends TypeAdapter<TimeProportion> {
  @override
  final int typeId = 1;

  @override
  TimeProportion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeProportion(
      day: fields[0] as String,
      allocatedProportion: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TimeProportion obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.allocatedProportion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeProportionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
