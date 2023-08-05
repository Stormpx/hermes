

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/model/Repository.dart';

class BuildingListModel  extends ChangeNotifier{

  BuildingRepository repository=Repo.buildingRepository;


  List<Building> buildings=[];

  void _init() async {

    buildings = await repository.findAll();

    notifyListeners();
  }



  void buildingReorder(int oldIndex, int newIndex) async{
    if(oldIndex<newIndex){
      newIndex--;
    }
    var building = buildings.removeAt(oldIndex);
    building = building.copyWith(sort: Value(newIndex));
    buildings.insert(newIndex, building);
    var b = await Repo.buildingRepository.save(building);
    notifyListeners();
  }

  void saveNewBuilding(Building building) async{
    await Repo.buildingRepository.save(building);
    buildings.add(building);
    notifyListeners();
  }

}