// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temporary_room_selected_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomSelectedAdapter extends TypeAdapter<RoomSelected> {
  @override
  final int typeId = 3;

  @override
  RoomSelected read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoomSelected(
      roomName: fields[0] as String,
      roomKey: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RoomSelected obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.roomName)
      ..writeByte(1)
      ..write(obj.roomKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomSelectedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
