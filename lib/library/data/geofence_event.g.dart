// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofence_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GeofenceEventAdapter extends TypeAdapter<GeofenceEvent> {
  @override
  final int typeId = 3;

  @override
  GeofenceEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GeofenceEvent(
      status: fields[0] as String?,
      user: fields[6] as User?,
      geofenceEventId: fields[1] as String?,
      projectPositionId: fields[3] as String?,
      projectName: fields[4] as String?,
      userId: fields[5] as String?,
      date: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GeofenceEvent obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.status)
      ..writeByte(1)
      ..write(obj.geofenceEventId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.projectPositionId)
      ..writeByte(4)
      ..write(obj.projectName)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeofenceEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
