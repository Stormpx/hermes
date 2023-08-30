

import 'package:hermes/kit/Util.dart';
import 'package:hermes/model/Database.dart';

class FloorWithRooms {

  final Floor floor;
  final List<Room> rooms;

  FloorWithRooms(this.floor, this.rooms);

  @override
  String toString() {
    return 'FloorWithRooms{floor: $floor, rooms: $rooms}';
  }
}

class RoomWithOptFee{

  final Room room;
  final List<RoomOption> optFee;

  RoomWithOptFee(this.room, this.optFee);

  @override
  String toString() {
    return 'RoomWithOptFee{room: $room, optFee: $optFee}';
  }
}

class RoomSnapshotRecord{
  final RoomSnapshot snapshot;
  final List<RoomSnapshotItem> items;

  String get startDate => Util.formatDay(snapshot.snapshotStartDate);
  String get endDate => Util.formatDay(snapshot.snapshotEndDate);


  RoomSnapshotRecord(this.snapshot, this.items);

  @override
  String toString() {
    return 'RoomSnapshotRecord{snapshot: $snapshot, items: $items}';
  }
}