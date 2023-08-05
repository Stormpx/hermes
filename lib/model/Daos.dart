
import 'package:drift/drift.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/model/Repository.dart';

part 'Daos.g.dart';




@DriftAccessor(tables: [Buildings])
class BuildingDao extends DatabaseAccessor<HermesDatabase> with BuildingRepository,_$BuildingDaoMixin {

  BuildingDao(HermesDatabase attachedDatabase) : super(attachedDatabase);

  @override
  Future<List<Building>> findAll() {
      return (select(buildings)..orderBy([
        (u)=> OrderingTerm(expression: buildings.sort,mode: OrderingMode.asc)
      ])).get();
  }

  @override
  Future<int> save(Building building) {
    if(building.id==null){
      //insert
      return (into(buildings).insert(building));
    }else{
      //update
      var id = building.id!;
      return (update(buildings)..where((tbl) => tbl.id.equals(id))).replace(building).then((value) => id);
    }
  }

}

@DriftAccessor(tables: [Floors])
class FloorDao extends DatabaseAccessor<HermesDatabase> with FloorRepository,_$FloorDaoMixin {
  
  FloorDao(HermesDatabase attachedDatabase) : super(attachedDatabase);

  @override
  Future<List<Floor>> findAll() {
    return (
        select(floors)
          ..orderBy([
            (u)=>OrderingTerm(expression: floors.sort,mode: OrderingMode.asc)
          ])
    ).get();
  }


}