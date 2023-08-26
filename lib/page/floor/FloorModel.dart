import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermes/App.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/model/Data.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/model/Repository.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_printer/flutter_printer.dart';

class FloorModel extends ChangeNotifier {
  static final String FLOOR_LIST_KEYS = "hemers:floors";

  TextEditingController floorNameController = TextEditingController();
  TextEditingController floorSortController = TextEditingController();

  int buildingId;

  List<FloorWithRooms> list = [];

  int? selectedFloorId;

  Floor? currFloor;

  List<Floor> get floor => list.map((e) => e.floor).toList();

  FloorModel(this.buildingId) {
    _init();
  }

  Future<void> _init() async {

    var result = await Repo.floorRepository.findAllByBuilding(buildingId);
    Printer.info(result);
    list = result;

    notifyListeners();
  }

  List<Room> getRooms(int floorId) {
    return list
            .where((element) => element.floor.id == floorId)
            .singleOrNull
            ?.rooms ??
        [];
  }

  Future<void> reloadRoomInFloor(int floorId,int roomId) async{
    var floorWithRoom = list.where((element) => element.floor.id==floorId).singleOrNull;
    if(floorWithRoom==null){
      return;
    }
    var room = await Repo.roomRepository.findById(roomId);
    if(room==null){
      return;
    }
    var index = floorWithRoom.rooms.indexWhere((r) => r.id==roomId);
    floorWithRoom.rooms.removeAt(index);
    floorWithRoom.rooms.insert(index,room);

    notifyListeners();

  }

  void floorReorder(int oldIndex, int newIndex) async {

    var floorWithRooms = list.elementAt(oldIndex);
    if(newIndex>oldIndex) {
      list.insert(newIndex, floorWithRooms);
      list.removeAt(oldIndex);
    }else {
      list.removeAt(oldIndex);
      list.insert(newIndex, floorWithRooms);
    }
    Repo.floorRepository.runOnScope(()async{
      for(final elem in list.indexed) {
        await Repo.floorRepository.save(elem.$2.floor.copyWith(sort: Value(elem.$1)));
      }
    });
    // notifyListeners();
  }

  void selectFloor(Floor? floor) {

    this.selectedFloorId=floor?.id;
    notifyListeners();
  }

  Future<bool> addFloor(String name) async {
    if (name.isEmpty) {
      return false;
    }
    var f = Floor(buildingId: buildingId, name: name, sort: 99);

    if (await Repo.floorRepository.nameExists(buildingId, name)) {
      Toast.show("不能添加已存在的item", gravity: Toast.bottom);
      return false;
    }

    f = await Repo.floorRepository.save(f);

    list.add(FloorWithRooms(f, []));

    notifyListeners();
    return true;
  }

  Future<bool> updateFloor(int floorId,String name) async {
    var floor = list.where((element) => element.floor.id==floorId).map((e) => e.floor).firstOrNull;

    if(floor==null){
      return false;
    }

    floor = await Repo.floorRepository.save(floor.copyWith(name: name));

    await _init();

    notifyListeners();
    return true;
  }

  Future<void> deleteFloor(FloorWithRooms floorWithRooms) async{
    Printer.printMapJsonLog(floorWithRooms);

    await Repo.roomRepository.runOnScope(()async {
      for(final room in floorWithRooms.rooms){
        await Repo.roomRepository.del(room.id as Object);
      }
      await Repo.floorRepository.del(floorWithRooms.floor.id as Object);
    });

    list.removeWhere((element) => element.floor.id==floorWithRooms.floor.id);

    notifyListeners();
  }


  Future<bool> addRoom(int floorId, String name) async {


    var newRoom = await Repo.roomRepository.save(Room(floorId: floorId,sort: 99, name: name,rent: 0,electFee: 0,waterFee: 0));

    getRooms(floorId).add(newRoom);

    notifyListeners();
    return true;
  }

  Future<bool> updateRoom(int roomId, String name) async{

    var oldRoom = await Repo.roomRepository.findById(roomId);
    if(oldRoom==null){
        return false;
    }
    Repo.roomRepository.save(oldRoom.copyWith(name:name));

    await _init();
    notifyListeners();
    return true;
  }

  Future<void> delRoom(FloorWithRooms floorWithRooms,Room room) async{
    await Repo.roomRepository.runOnScope(() => Repo.roomRepository.del(room.id!));
    floorWithRooms.rooms.remove(room);
    notifyListeners();
  }

}
