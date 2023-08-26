
import 'package:hermes/App.dart';
import 'package:hermes/model/Data.dart';
import 'package:hermes/model/Database.dart';

abstract class CrudRepository<Entity>{



  Future<Entity?> findById(Object id);

  Future<List<Entity>> findAll();

  Future<Entity> save(Entity entity);

  Future<bool> del(Object k);

  Future<T> runOnScope<T>(Future<T> Function() action);

}

abstract class BuildingRepository extends CrudRepository<Building>{


  // Future<int> save(Building building);

}
abstract class FloorRepository extends CrudRepository<Floor>{

  Future<List<Floor>> findAllById(int buildingId);

  Future<List<FloorWithRooms>> findAllByBuilding(int buildingId);

  Future<FloorWithRooms?> findFloorById(int floorId);

  Future<bool> nameExists(int buildingId,String name);

}

abstract class RoomRepository extends CrudRepository<Room>{

  Future<RoomWithOptFee?> findRoom(int roomId);

  Future<void> saveOptFees(int roomId,List<RoomOption> optFees);

  Future<List<RoomDay>> findDaysById(int roomId,DateTime start,DateTime end);

  Future<RoomDay> saveDay(RoomDay day);

  Future<void> saveSnapshot(RoomSnapshotRecord snapshot);

  Future<List<RoomSnapshotRecord>> findSnapshotByRoomId(int roomId);

  Future<bool> delSnapshotById(int snapshotId);

}


class Repo{

  static BuildingRepository buildingRepository=App.database.buildingsDao;

  static FloorRepository floorRepository=App.database.floorsDao;

  static RoomRepository roomRepository=App.database.roomsDao;

}
