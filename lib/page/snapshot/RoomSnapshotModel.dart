import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hermes/App.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/model/FeeResult.dart';
import 'package:hermes/page/roomlist/Room.dart';


class RoomSnapshotModel extends ChangeNotifier{
  
  Room room;


  RoomSnapshotModel(this.room){
    _init();
  }
  
  
  void _init() async{
    notifyListeners();
  }
  
  List<FeeSnapshot> getSnapshot(){
    String prefix="${room.name}${FeeSnapshot.room_fee_snapshot_key}";
    var list=App.sharedPreferences!.getKeys()
        .where((str) => str.startsWith(prefix))
        .toList()
    ;

    list.sort((str1,str2){
      DateTime dt1=Util.parseDay(str1.substring(prefix.length+1));
      DateTime dt2=Util.parseDay(str2.substring(prefix.length+1));

      return dt2.compareTo(dt1);
    });
    return list
        .map((e) => App.sharedPreferences!.getString(e))
        .map((e) => FeeSnapshot.fromJson(jsonDecode(e!)))
        .toList();

  }

  
  
  
}