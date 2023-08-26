
import 'package:drift/drift.dart';
import 'package:hermes/App.dart';
import 'package:hermes/model/Data.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/model/Repository.dart';

part 'Daos.g.dart';

abstract class BaseDao<Entity extends Insertable<Entity>,R extends CrudRepository<Entity>> extends DatabaseAccessor<HermesDatabase> implements CrudRepository<Entity>{
  BaseDao(HermesDatabase attachedDatabase) : super(attachedDatabase);
  
  TableInfo<Table,Entity> tableInfo();

  Future<T> runOnScope<T>(Future<T> Function() action) async{
    return App.database.transaction(action);
  }

  @override
  Future<bool> del(Object k) {
    return tableInfo().deleteById(k);
  }

  @override
  Future<Entity?> findById(Object id) {
    return tableInfo().findById(id).getSingleOrNull();
  }

  @override
  Future<List<Entity>> findAll() {
    return select(tableInfo()).get();
  }

  @override
  Future<Entity> save(Entity entity) {
    return tableInfo().insertReturning(entity,mode: InsertMode.insertOrReplace);
  }

}


@DriftAccessor(tables: [Buildings])
class BuildingsDao extends BaseDao<Building,BuildingRepository> with _$BuildingsDaoMixin implements BuildingRepository{

  BuildingsDao(HermesDatabase attachedDatabase) : super(attachedDatabase);

  @override
  TableInfo<Table, Building> tableInfo() {
    return buildings;
  }


}

@DriftAccessor(tables: [Floors])
class FloorsDao extends BaseDao<Floor,FloorRepository> with _$FloorsDaoMixin implements FloorRepository {

  FloorsDao(HermesDatabase attachedDatabase) : super(attachedDatabase);

  @override
  TableInfo<Table, Floor> tableInfo() {
    return floors;
  }
  
  @override
  Future<List<Floor>> findAllById(int buildingId) {
    return (
        select(floors)
          ..where((tbl) => tbl.buildingId.equals(buildingId))
          ..orderBy([
            (u)=>OrderingTerm(expression: floors.sort,mode: OrderingMode.asc)
          ])
    ).get();
  }

  @override
  Future<bool> nameExists(int buildingId, String name)  async{
     var count = await (selectOnly(floors)
      ..addColumns([floors.id.count()])
      ..where(floors.buildingId.equals(buildingId))
      ..where(floors.name.equals(name)))
         .map((p0) => p0.read(floors.id.count()))
         .getSingle();

     return (count??0) >0;
  }

  @override
  Future<List<FloorWithRooms>> findAllByBuilding(int buildingId) async{
    var floorList = await findAllById(buildingId);

    var rows = floorList.isEmpty?[]:await (select(attachedDatabase.rooms)
      ..where((tbl) => attachedDatabase.rooms.floorId.isIn(floorList.map((e) => e.id!).toList())))
        .get();

    final idToItems = <int, List<Room>>{};
    for (final room in rows) {
      idToItems.putIfAbsent(room.floorId, () => []).add(room);
    }
    return [
      for (final floor in floorList)
        FloorWithRooms(floor, idToItems[floor.id]??[])
    ];
  }

  @override
  Future<FloorWithRooms?> findFloorById(int floorId) async{
    var floor = await findById(floorId);
    if(floor==null){
      return null;
    }

    var rows = await (select(attachedDatabase.rooms)
      ..where((tbl) => attachedDatabase.rooms.floorId.equals(floor.id!)))
        .get();
    return FloorWithRooms(floor, rows);

  }

}

@DriftAccessor(tables: [Rooms,RoomOptions,RoomDays,RoomSnapshots,RoomSnapshotItems])
class RoomsDao extends BaseDao<Room,RoomRepository> with _$RoomsDaoMixin implements RoomRepository {
  RoomsDao(HermesDatabase attachedDatabase) : super(attachedDatabase);

  @override
  TableInfo<Table, Room> tableInfo() {
    return rooms;
  }

  @override
  Future<bool> del(Object k) async{
    await (delete(rooms)..where((tbl) => tbl.id.equals(k as int))).go();
    await (delete(roomOptions)..where((tbl) => tbl.roomId.equals(k as int))).go();
    await (delete(roomDays)..where((tbl) => tbl.roomId.equals(k as int))).go();
    await (delete(roomSnapshots)..where((tbl) => tbl.roomId.equals(k as int))).go();
    await (delete(roomSnapshotItems)..where((tbl) => tbl.roomId.equals(k as int))).go();
    return true;
  }

  @override
  Future<List<RoomDay>> findDaysById(int roomId, DateTime start, DateTime end) {
    return (
      select(roomDays)
      ..where((tbl) => tbl.roomId.equals(roomId))
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start))
      ..where((tbl) => tbl.date.isSmallerOrEqualValue(end))
    ).get();
  }

  @override
  Future<RoomWithOptFee?> findRoom(int roomId) async{
    var room = await findById(roomId);
    if(room==null){
      return null;
    }
    var optFees = await (
      select(roomOptions)
        ..where((tbl) => tbl.roomId.equals(roomId))
        ..orderBy([
              (u)=>OrderingTerm(expression: roomOptions.id,mode: OrderingMode.asc)
        ])
    ).get();

    return RoomWithOptFee(room, optFees);
  }

  @override
  Future<List<RoomSnapshotRecord>> findSnapshotByRoomId(int roomId) async{
    var snapshots = await (
      select(roomSnapshots)
        ..where((tbl) => tbl.roomId.equals(roomId))
        ..orderBy([
              (u)=>OrderingTerm(expression: roomSnapshots.snapshotStartDate,mode: OrderingMode.desc)
        ])
    ).get();

    var items = snapshots.isEmpty?[]:await (
        select(roomSnapshotItems)
          ..where((tbl) => tbl.roomId.equals(roomId))
          ..where((tbl) => tbl.snapshotId.isIn(snapshots.map((e) => e.id!)))
    ).get();

    var itemMap=<int, List<RoomSnapshotItem>>{};

    for (final item in items) {
      itemMap.putIfAbsent(item.snapshotId,() => []).add(item);
    }

    return [
      for (final snapshot in snapshots)
        RoomSnapshotRecord(snapshot, itemMap[snapshot.id]??[])
    ];
  }

  @override
  Future<RoomDay> saveDay(RoomDay day) {
    return (
      into(roomDays)
        .insertReturning(day,mode: InsertMode.insertOrReplace)
    );
  }

  @override
  Future<void> saveOptFees(int roomId,List<RoomOption> optFees) async {
    await (delete(roomOptions)..where((tbl) => tbl.roomId.equals(roomId))).go();
    for(final fee in optFees){
      await (
          into(roomOptions)
              .insertReturning(RoomOption(roomId: roomId, name: fee.name,fee: fee.fee),mode: InsertMode.insertOrReplace)
      );
    }
  }

  @override
  Future<void> saveSnapshot(RoomSnapshotRecord record) async {
    var snapshot = await (
        into(roomSnapshots)
            .insertReturning(record.snapshot,mode: InsertMode.insertOrReplace)
    );

    for (var item in record.items) {
      await (
        into(roomSnapshotItems)
          .insertReturning(item.copyWith(roomId: snapshot.roomId,snapshotId: snapshot.id),mode: InsertMode.insertOrReplace)
      );
    }
  }

  @override
  Future<bool> delSnapshotById(int snapshotId) async{
    var result = await (delete(roomSnapshots)..where((tbl) => tbl.id.equals(snapshotId))).go();
    if(result>0){
      await (delete(roomSnapshotItems)..where((tbl) => tbl.snapshotId.equals(snapshotId))).go();
      return true;
    }
    return false;
  }

}