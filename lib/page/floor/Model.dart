

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

class Model extends ChangeNotifier{

  static final String FLOOR_LIST_KEYS="hemers:floors";


  List<Floor> _list=[

  ];


  Model(){

    _init();

  }


  List<Floor> get list {
//    var jsonArray=App.sharedPreferences.getString(FLOOR_LIST_KEYS);
//    Printer.printMapJsonLog(jsonArray);
//    if(jsonArray==null||jsonArray.isEmpty)
//      return [];
//    List<dynamic> list=jsonDecode(jsonArray);
//
//    List<Floor> floors=list.map((e) => Floor.fromJson(e)).toList();
//    floors.sort((f,f2)=>f.name.compareTo(f2.name));
//    _list=floors;

    return _list;
  }

  void _init() async {
    var jsonArray=App.sharedPreferences.getString(FLOOR_LIST_KEYS);
    if(jsonArray==null||jsonArray.isEmpty){

      _list=[];
    }else {
      List<dynamic> list = jsonDecode(jsonArray);

      List<Floor> floors = list.map((e) => Floor.fromJson(e)).toList();
      floors.sort((f, f2) => f.name.compareTo(f2.name));
      _list = floors;
    }

    notifyListeners();

  }


  TextEditingController floorNameController = TextEditingController();
  TextEditingController floorSortController = TextEditingController();


  void onAddFloor(BuildContext context) async {
    var f=Floor(
        name: floorNameController.text,
        sort: floorSortController.text.isEmpty?99:int.parse(floorSortController.text)
    );
    if(f==null||f.name.isEmpty){
      return;
    }

    if(list.any((element) => element==f)){
      Toast.show("不能添加已存在的item", context,gravity: Toast.BOTTOM);
      return ;
    }
    list.add(f);
    list.sort((f1,f2){
      return f1.name.compareTo(f2.name);
    });


    floorNameController.clear();
    floorSortController.clear();

    var b=await App.sharedPreferences.setString(FLOOR_LIST_KEYS,jsonEncode(list));

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

  String getDataEncoded(){
    var data={};
    App.sharedPreferences.getKeys()
        .forEach((element) {
      var v=App.sharedPreferences.getString(element);
      data[element]=v;
    });

    var str=base64.encode(GZipEncoder().encode(utf8.encode(jsonEncode(data))));

    Printer.printMapJsonLog(str);

    return str;
  }

  void export2clipboard(BuildContext context){
    var str=getDataEncoded();
    Clipboard.setData(ClipboardData(text: str));
    Toast.show("复制成功 数据长度:${str.length}", context,duration: 2,gravity: Toast.BOTTOM);
  }

  Future<void> export2File(BuildContext context) async {
    var status=await Permission.storage.request();
    if(!status.isGranted){
      return;
    }

    var str=getDataEncoded();
//    Directory d = App.exDirectory;
//    Printer.printMapJsonLog(d.path);
//    if(d!=null&& await d.exists()){
//       var hermesDirectory=Directory("$d/hermes");
//       if(! await hermesDirectory.exists())
//          await hermesDirectory.create();
//       var file=File("${hermesDirectory.path}/${Util.formatDay(DateTime.now())}.hermes");
//       await file.writeAsString(str);
//
//       Printer.printMapJsonLog(file.path);
//       Toast.show("导出成功 路径:${file.path}", context,duration: 5,gravity: Toast.BOTTOM);
//
//    }
//    /storage/emulated/0
    var d=Directory("/storage/emulated/0/hermes");
    if(! await d.exists())
        await d.create(recursive: true);
    var file=File("/storage/emulated/0/hermes/${Util.formatDay(DateTime.now())}.hermes");
    await file.writeAsString(str);

    Printer.printMapJsonLog(file.path);
    Toast.show("导出成功 路径:${file.path}", context,duration: 5,gravity: Toast.BOTTOM);


  }

  /// only for test
  void clearData(BuildContext context) async{
    await App.sharedPreferences.clear();
    Toast.show("数据已清除", context,duration: 2,gravity: Toast.BOTTOM);
    _init();
  }

  void route2Import(BuildContext context) async{
    await Navigator.push(context, MaterialPageRoute(
        builder: (c)=>ChangeNotifierProvider(
          create: (c)=>ImportModel(),
          child: Import(),
        )
    ));
    _init();
  }

}