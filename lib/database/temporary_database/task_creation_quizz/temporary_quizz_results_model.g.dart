// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temporary_quizz_results_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizzResultsAdapter extends TypeAdapter<QuizzResults> {
  @override
  final int typeId = 5;

  @override
  QuizzResults read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizzResults(
      question: fields[0] as int,
      rank: fields[1] as int,
      answer: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuizzResults obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.rank)
      ..writeByte(2)
      ..write(obj.answer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizzResultsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
