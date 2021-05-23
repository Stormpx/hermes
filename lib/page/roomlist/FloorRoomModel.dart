import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hermes/App.dart';
import 'package:hermes/page/floor/Floor.dart';
import 'package:hermes/page/room/RoomModel.dart';
import 'package:hermes/page/room/RoomPage.dart';
import 'package:hermes/page/roomlist/Room.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';


class FloorRoomModel extends ChangeNotifier{
  static final String FLOOR_PREFIX="hermes:floor:";

  String _keyPrefix;

  Floor floor;

  List<Room> rooms=[

  ];


  FloorRoomModel(this.floor){
    _init();
  }

  TextEditingController roomNameController = TextEditingController();

  void _init() async{
    _keyPrefix="${App.hermesKeyPrefix}${floor.name}:";
    var arrayStr =  App.sharedPreferences.getString("$FLOOR_PREFIX+${floor.name}");
//    var arrayStr = App.sharedPreferences.getString(_keyPrefix);
    if(arrayStr==null||arrayStr.isEmpty)
      return ;

    List<dynamic> list=jsonDecode(arrayStr);
    List<Room> r=list.map((e) => Room.fromJson(e)).toList();
    r.sort((r1,r2)=>r1.sort.compareTo(r2.sort));
    this.rooms=r;
    notifyListeners();
  }

  Fee getFee(Room room){
      var str= App.sharedPreferences.getString("${room.name}${RoomModel.FEE_KEY}");
//      var str= App.sharedPreferences.getString("$_keyPrefix${room.name}${RoomModel.FEE_KEY}");
      print(str);
      if(str==null)
        return null;
      return Fee.fromJson(jsonDecode(str));
  }

  addRoom(BuildContext context){

    var f=Room(
      name: roomNameController.text,
      sort:99
    );

    if(rooms.any((element) => element==f)){
      Toast.show("不能添加已存在的item", context,gravity: Toast.BOTTOM);
      return ;
    }

    rooms.add(f);

    rooms.sort((f1,f2){
      return f1.name.compareTo(f2.name);
    });

    roomNameController.clear();

    App.sharedPreferences.setString("$FLOOR_PREFIX+${floor.name}", jsonEncode(rooms));
//    App.sharedPreferences.setString("$_keyPrefix${floor.name}", jsonEncode(rooms));

    notifyListeners();
  }

  enterRoom(BuildContext context,Room room) async{
    print("enter room ${room.name}");
    await Navigator.push(context, MaterialPageRoute(
        builder: (c)=>ChangeNotifierProvider(
          create: (c)=>RoomModel(floor,room),
          child: RoomPage(),
        )
    ));
    notifyListeners();
  }
}