// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CityAdapter extends TypeAdapter<City> {
  @override
  final int typeId = 7;

  @override
  City read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return City(
      name: fields[0] as String?,
      countryId: fields[1] as String?,
      provinceName: fields[3] as String?,
      countryName: fields[2] as String?,
      position: fields[6] as Position?,
      created: fields[5] as String?,
    )..cityId = fields[4] as String?;
  }

  @override
  void write(BinaryWriter writer, City obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.countryId)
      ..writeByte(2)
      ..write(obj.countryName)
      ..writeByte(3)
      ..write(obj.provinceName)
      ..writeByte(4)
      ..write(obj.cityId)
      ..writeByte(5)
      ..write(obj.created)
      ..writeByte(6)
      ..write(obj.position);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
