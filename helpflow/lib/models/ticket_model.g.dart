// GENERATED CODE - DO NOT MODIFY BY HAND
// build_runner 실행 시 이 파일은 자동 재생성됩니다.
// 명령: flutter pub run build_runner build --delete-conflicting-outputs

part of 'ticket_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

/// TicketModel Hive TypeAdapter (typeId: 0)
class TicketModelAdapter extends TypeAdapter<TicketModel> {
  @override
  final int typeId = 0;

  @override
  TicketModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TicketModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      status: fields[3] as TicketStatus,
      priority: fields[4] as TicketPriority,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      assignee: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TicketModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.assignee);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

/// TicketStatus Hive TypeAdapter (typeId: 1)
class TicketStatusAdapter extends TypeAdapter<TicketStatus> {
  @override
  final int typeId = 1;

  @override
  TicketStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TicketStatus.newTicket;
      case 1:
        return TicketStatus.inProgress;
      case 2:
        return TicketStatus.done;
      case 3:
        return TicketStatus.onHold;
      default:
        return TicketStatus.newTicket;
    }
  }

  @override
  void write(BinaryWriter writer, TicketStatus obj) {
    switch (obj) {
      case TicketStatus.newTicket:
        writer.writeByte(0);
      case TicketStatus.inProgress:
        writer.writeByte(1);
      case TicketStatus.done:
        writer.writeByte(2);
      case TicketStatus.onHold:
        writer.writeByte(3);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

/// TicketPriority Hive TypeAdapter (typeId: 2)
class TicketPriorityAdapter extends TypeAdapter<TicketPriority> {
  @override
  final int typeId = 2;

  @override
  TicketPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TicketPriority.low;
      case 1:
        return TicketPriority.medium;
      case 2:
        return TicketPriority.high;
      case 3:
        return TicketPriority.urgent;
      default:
        return TicketPriority.medium;
    }
  }

  @override
  void write(BinaryWriter writer, TicketPriority obj) {
    switch (obj) {
      case TicketPriority.low:
        writer.writeByte(0);
      case TicketPriority.medium:
        writer.writeByte(1);
      case TicketPriority.high:
        writer.writeByte(2);
      case TicketPriority.urgent:
        writer.writeByte(3);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
