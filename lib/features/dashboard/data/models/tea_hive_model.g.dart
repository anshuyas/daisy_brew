// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tea_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeaHiveModelAdapter extends TypeAdapter<TeaHiveModel> {
  @override
  final int typeId = 2;

  @override
  TeaHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TeaHiveModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      image: fields[2] as String?,
      price: fields[3] as int,
      isAvailable: fields[4] as bool,
      category: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TeaHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.isAvailable)
      ..writeByte(5)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeaHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
