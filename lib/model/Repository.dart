
import 'package:hermes/App.dart';
import 'package:hermes/model/Daos.dart';
import 'package:hermes/model/Database.dart';


abstract class BuildingRepository {

  Future<List<Building>> findAll();

  Future<int> save(Building building);

}
abstract class FloorRepository {

  Future<List<Floor>> findAll();

}


class Repo{

  static BuildingRepository buildingRepository=BuildingDao(App.database);



}
