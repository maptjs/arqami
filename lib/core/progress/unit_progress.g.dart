// GENERATED CODE - DO NOT MODIFY BY HAND
// (هذا الملف مكتوب يدوياً بنفس صيغة build_runner تماماً.
//  إذا شغّلت `flutter pub run build_runner build` لاحقاً، غيعاود يولّد
//  نفس المحتوى ويستبدل هاد الملف بأمان.)

part of 'unit_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitProgressAdapter extends TypeAdapter<UnitProgress> {
  @override
  final int typeId = 10;

  @override
  UnitProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitProgress(
      unitId: fields[0] as String,
      completed: fields[1] as bool,
      stars: fields[2] as int,
      lastAttemptAt: fields[3] as DateTime?,
      attemptsCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UnitProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.unitId)
      ..writeByte(1)
      ..write(obj.completed)
      ..writeByte(2)
      ..write(obj.stars)
      ..writeByte(3)
      ..write(obj.lastAttemptAt)
      ..writeByte(4)
      ..write(obj.attemptsCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
