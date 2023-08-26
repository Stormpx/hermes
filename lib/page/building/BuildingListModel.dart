

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/model/Repository.dart';

class BuildingListModel  extends ChangeNotifier{

  BuildingRepository repository=Repo.buildingRepository;


  List<Building> buildings=[];


  BuildingListModel(){
  }

  Future<BuildingListModel> init() async {

    buildings = (await repository.findAll());
    buildings.sort((a,b)=>a.sort??99.compareTo(b.sort??99));
    return this;
  }

  Future<void> reload()async{
    await init();
    notifyListeners();
  }

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
    notifyListeners();
  }

  Future<void> updateBuilding(String name,Building building) async{
    await Repo.buildingRepository.save(building.copyWith(name: name));
    await reload();
  }

}