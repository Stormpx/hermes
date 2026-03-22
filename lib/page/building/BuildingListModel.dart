

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/model/Repository.dart';

class BuildingListModel  extends ChangeNotifier{

  BuildingRepository repository=Repo.buildingRepository;


  List<Building> buildings=[];
  Map<int, int> floorCounts={};
  Map<int, int> roomCounts={};


  BuildingListModel(){
  }

  Future<BuildingListModel> init() async {

    buildings = (await repository.findAll());
    buildings.sort((a,b)=>a.sort??99.compareTo(b.sort??99));
    await _loadCounts();
    return this;
  }

  Future<void> _loadCounts() async {
    floorCounts = {};
    roomCounts = {};
    for (final building in buildings) {
      if (building.id == null) continue;
      final floors = await Repo.floorRepository.findAllByBuilding(building.id!);
      floorCounts[building.id!] = floors.length;
      int totalRooms = 0;
      for (final f in floors) {
        totalRooms += f.rooms.length;
      }
      roomCounts[building.id!] = totalRooms;
    }
  }

  Future<void> reload()async{
    await init();
    notifyListeners();
  }

  int getFloorCount(int? buildingId) => floorCounts[buildingId] ?? 0;
  int getRoomCount(int? buildingId) => roomCounts[buildingId] ?? 0;

  void buildingReorder(int oldIndex, int newIndex) async{
    // if(oldIndex<newIndex){
    //   newIndex--;
    // }
    var building = buildings.elementAt(oldIndex);
    if(newIndex>oldIndex) {
      buildings.insert(newIndex, building);
      buildings.removeAt(oldIndex);
    }else {
      buildings.removeAt(oldIndex);
      buildings.insert(newIndex, building);
    }
    Repo.buildingRepository.runOnScope(()async{
      for(final elem in buildings.indexed) {
        await Repo.buildingRepository.save(elem.$2.copyWith(sort: Value(elem.$1)));
      }
    });


    // notifyListeners();
  }

  void saveNewBuilding(Building building) async{
    building = await Repo.buildingRepository.save(building);

    buildings.add(building);
    if (building.id != null) {
      floorCounts[building.id!] = 0;
      roomCounts[building.id!] = 0;
    }
    notifyListeners();
  }

  Future<void> delBuilding(Building building) async{
    await Repo.buildingRepository.runOnScope(() async{
      var floor = await Repo.floorRepository.findAllByBuilding(building.id!);
      for(final fwr in floor){
        for(final r  in fwr.rooms){
          await Repo.roomRepository.del(r.id!);
        }
        await Repo.floorRepository.del(fwr.floor.id!);
      }
      await Repo.buildingRepository.del(building.id!);
    });
    buildings.remove(building);
    floorCounts.remove(building.id);
    roomCounts.remove(building.id);
    notifyListeners();
  }

  Future<void> updateBuilding(String name,Building building) async{
    await Repo.buildingRepository.save(building.copyWith(name: name));
    await reload();
  }

}