// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Daos.dart';

// ignore_for_file: type=lint
mixin _$BuildingsDaoMixin on DatabaseAccessor<HermesDatabase> {
  $BuildingsTable get buildings => attachedDatabase.buildings;
}
mixin _$FloorsDaoMixin on DatabaseAccessor<HermesDatabase> {
  $FloorsTable get floors => attachedDatabase.floors;
}
mixin _$RoomsDaoMixin on DatabaseAccessor<HermesDatabase> {
  $RoomsTable get rooms => attachedDatabase.rooms;
  $RoomOptionsTable get roomOptions => attachedDatabase.roomOptions;
  $RoomDaysTable get roomDays => attachedDatabase.roomDays;
  $RoomSnapshotsTable get roomSnapshots => attachedDatabase.roomSnapshots;
  $RoomSnapshotItemsTable get roomSnapshotItems =>
      attachedDatabase.roomSnapshotItems;
}
