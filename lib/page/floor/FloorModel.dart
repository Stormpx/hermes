

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermes/App.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/page/floor/Floor.dart';
import 'package:hermes/page/import/Import.dart';
import 'package:hermes/page/import/ImportModel.dart';
import 'package:hermes/page/roomlist/FloorRoomModel.dart';
import 'package:hermes/page/roomlist/FloorRoomsPage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_printer/flutter_printer.dart';

class FloorModel extends ChangeNotifier{

  static final String FLOOR_LIST_KEYS="hemers:floors";


  List<Floor> _list=[

  ];

  Floor? _currFloor;

  FloorModel(){

    _init();

  }


  List<Floor> get list {
    return _list;
  }

  Floor? get currFloor{
    return _currFloor;
  }

  void _init() async {
    var jsonArray=App.sharedPreferences!.getString(FLOOR_LIST_KEYS);
    if(jsonArray==null||jsonArray.isEmpty){

      _list=[];
    }else {
      List<dynamic> list = jsonDecode(jsonArray);

      List<Floor> floors = list.map((e) => Floor.fromJson(e)).toList();
//      floors.sort((f, f2) => f.name.compareTo(f2.name));
      _list = floors;
    }

    notifyListeners();

  }


  TextEditingController floorNameController = TextEditingController();
  TextEditingController floorSortController = TextEditingController();


  void floorReorder(int oldIndex,int newIndex) async{
    if(oldIndex<newIndex){
      newIndex--;
    }
      var floor = _list.removeAt(oldIndex);
      _list.insert(newIndex, floor);
    var b=await App.sharedPreferences!.setString(FLOOR_LIST_KEYS,jsonEncode(list));
    Printer.printMapJsonLog("content???????");
      notifyListeners();
  }

  void selectFloor(Floor? floor){
    this._currFloor=floor;
    notifyListeners();
  }


  void onAddFloor(BuildContext context,String name) async {
    var f=Floor(
        name: name,
        sort: 99
    );
    if(f.name.isEmpty){
      return;
    }

    if(list.any((element) => element==f)){
      Toast.show("不能添加已存在的item", gravity: Toast.bottom);
      return ;
    }
    list.add(f);
//    list.sort((f1,f2){
//      return f1.name.compareTo(f2.name);
//    });



    var b=await App.sharedPreferences!.setString(FLOOR_LIST_KEYS,jsonEncode(list));

    notifyListeners();
  }

  void onEditFloor(BuildContext context,String name) async{
    if(name.isEmpty){
      return;
    }

    this._currFloor?.name=name;

    var b=await App.sharedPreferences!.setString(FLOOR_LIST_KEYS,jsonEncode(list));

    this._currFloor=null;
    notifyListeners();
  }


  void onDelFloor(BuildContext buildContext,Floor floor,int index){

    _list.removeAt(index);
    notifyListeners();
  }

  void onEnterFloor(BuildContext context,Floor floor){
//    notifyListeners();
    print("enter floor ${floor.name} ");
    Navigator.push(context, MaterialPageRoute(
        builder: (c)=>ChangeNotifierProvider(
            create: (c)=>FloorRoomModel(floor),
            child: FloorRoomsPage(),
        )
    ));
  }

}