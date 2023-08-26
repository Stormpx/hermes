import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/App.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/model/Data.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/model/Repository.dart';
import 'package:hermes/page/room/Model.dart';

class LegacyFloor {
  String name;
  int sort = 99;

  List<LegacyRoom> rooms = [];

  LegacyFloor({required this.name, this.sort = 99});

  factory LegacyFloor.fromJson(Map<String, dynamic> json) {
    return LegacyFloor(
        name: json['name'] as String, sort: (json['sort'] as int?) ?? 99);
  }
}

class LegacyRoom {
  String name;

  int sort = 0;

  DateTime? lastSelectedDay;

  LegacyFee fee = LegacyFee();

  List<LegacyOptionFee> optionFees = [];

  List<LegacyRoomDay> roomDays = [];

  List<LegacyFeeSnapshot> feeSnapshot = [];

  LegacyRoom({required this.name, this.sort = 0});

  factory LegacyRoom.fromJson(Map<String, dynamic> json) {
    return LegacyRoom(
        name: json['name'] as String, sort: (json['sort'] as int?) ?? 0);
  }
}

class LegacyFee {
  double rent;
  double electFee;
  double waterFee;

  LegacyFee({this.rent = 0, this.electFee = 0, this.waterFee = 0});

  factory LegacyFee.fromJson(Map<String, dynamic> json) {
    return LegacyFee(
      rent: (json['rent'] as double?) ?? 0,
      electFee: (json['electFee'] as double?) ?? 0,
      waterFee: (json['waterFee'] as double?) ?? 0,
    );
  }
}

class LegacyOptionFee {
  String? name;
  double fee = 0;

  LegacyOptionFee({this.name, this.fee = 0});

  factory LegacyOptionFee.fromJson(Map<String, dynamic> json) {
    return LegacyOptionFee(
      name: json['name'] as String?,
      fee: (json['fee'] as double?) ?? 0.0,
    );
  }
}

class LegacyRoomDay {
  DateTime date;
  int elect;
  int water;

  LegacyRoomDay({required this.date, required this.elect, required this.water});

  factory LegacyRoomDay.fromJson(Map<String, dynamic> json) {
    return LegacyRoomDay(
        date: DateTime.parse(json['date'] as String),
        elect: (json['elect'] as int?) ?? 0,
        water: (json['water'] as int?) ?? 0);
  }
}

class LegacyFeeSnapshot {
  DateTime date;

  double electFee;
  double waterFee;
  double rent;

  double electAmount;
  double waterAmount;

  double total;

  List<FeeItem>? items;

  LegacyFeeSnapshot(
      {required this.date,
      required this.electFee,
      required this.waterFee,
      required this.rent,
      required this.total,
      this.items,
      required this.electAmount,
      required this.waterAmount});

  factory LegacyFeeSnapshot.fromJson(Map<String, dynamic> json) {
    return LegacyFeeSnapshot(
      date: Util.parseDay(json['date'] as String),
      electFee: (json['electFee'] as double?)??0,
      waterFee: (json['waterFee'] as double?)??0,
      rent: (json['rent'] as double?)??0,
      electAmount: (json['electAmount'] as double?)??0,
      waterAmount: (json['waterAmount'] as double?)??0,
      total: (json['total'] as double?)??0,
      items: (json['items'] as List?)?.where((e) => e['name']!=null).map((e) => FeeItem.fromJson(e)).toList(),
    );
  }
}

abstract class KvRepository{

  String? getString(String key);

  Iterable<String> keys();

  void remove(String key);
}

class SharedPreferencesKv extends KvRepository{
  @override
  String? getString(String key) {
    return App.sharedPreferences!.getString(key);
  }

  @override
  Iterable<String> keys() {
    return App.sharedPreferences!.getKeys();
  }

  @override
  void remove(String key) {
    App.sharedPreferences!.remove(key);
  }

}

class MapKv extends KvRepository{

  Map<String,dynamic> data;

  MapKv(this.data);

  @override
  String? getString(String key) {
    return data[key] as String?;
  }

  @override
  Iterable<String> keys() {
    return data.keys;
  }

  @override
  void remove(String key) {
    data.remove(key);
  }
}

class Rebuild{
  //floorlist
  static final String FLOOR_LIST_KEYS = "hemers:floors";

  //roomlist
  static final String FLOOR_PREFIX = "hermes:floor:";

  //room
  static final String DATE_KEY = ":date:";
  static final String FEE_KEY = ":fee";
  static final String OPTION_KEY = ":option:fee";
  static final String LAST_SELECT_KEY = "_LAST_SELECT";

  //snapshot
  static String room_fee_snapshot_key = ":room:fee:snapshot:";


  KvRepository _kvRepository;

  void Function(int)? progressCallback;

  Rebuild(this._kvRepository,{this.progressCallback});

  List<LegacyFloor> _getFloorList() {
    var json = _kvRepository.getString(FLOOR_LIST_KEYS) ?? "[]";
    List<dynamic> floors = jsonDecode(json);
    return floors.map((e) {
      var f = LegacyFloor.fromJson(e);
      f.rooms = _getRoomList(f.name);
      return f;
    }).toList();
  }

  List<LegacyRoom> _getRoomList(String floorName) {
    var json =
        _kvRepository.getString("$FLOOR_PREFIX+${floorName}") ?? "[]";
    List<dynamic> rooms = jsonDecode(json);
    return rooms.map((e) {
      var r = LegacyRoom.fromJson(e);
      r.fee = _getFee(r.name);
      r.optionFees = _getOptionFee(r.name);
      r.roomDays = _getRoomDay(r.name);
      r.lastSelectedDay = _getLastSelectedDay(r.name);
      r.feeSnapshot = _getFeeSnapshot(r.name);
      return r;
    }).toList();
  }

  LegacyFee _getFee(String roomName) {
    var str = _kvRepository.getString("${roomName}$FEE_KEY") ?? "{}";
    return LegacyFee.fromJson(jsonDecode(str));
  }

  List<LegacyOptionFee> _getOptionFee(String roomName) {
    var json =
        _kvRepository.getString("${roomName}$OPTION_KEY") ?? "[]";
    return (jsonDecode(json) as List<dynamic>)
        .map((e) => LegacyOptionFee.fromJson(e))
        .toList();
  }

  List<LegacyRoomDay> _getRoomDay(String roomName) {
    var prefix = "${roomName}$DATE_KEY";
    return _kvRepository
        .keys()
        .where((k) => k.startsWith(prefix))
        .map((e) => _kvRepository.getString(e))
        .where((element) => element != null)
        .map((e) => jsonDecode(e!))
        .where((json) => json["date"] != null)
        .map((e) => LegacyRoomDay.fromJson(e))
        .toList();
  }

  DateTime? _getLastSelectedDay(String roomName) {
    var date = _kvRepository.getString("${roomName}$LAST_SELECT_KEY");
    if (date != null) {
      return Util.parseDay(date);
    }
    return null;
  }

  List<LegacyFeeSnapshot> _getFeeSnapshot(String roomName) {
    String prefix = "${roomName}${room_fee_snapshot_key}";
    var list = _kvRepository
        .keys()
        .where((str) => str.startsWith(prefix))
        .toList();

    list.sort((str1, str2) {
      DateTime dt1 = Util.parseDay(str1.substring(prefix.length + 1));
      DateTime dt2 = Util.parseDay(str2.substring(prefix.length + 1));

      return dt1.compareTo(dt2);
    });
    return list
        .map((e) => _kvRepository.getString(e))
        .where((element) => element != null)
        .map((e) => jsonDecode(e!))
        .where((json) => json["date"] != null)
        .map((e) => LegacyFeeSnapshot.fromJson(e!))
        .toList();
  }





  Future<void> start() async {
    var floors = _getFloorList();
    if (floors.isEmpty) {
      return;
    }
    var callback = this.progressCallback??(p){};
    await Repo.floorRepository.runOnScope(() async {
      var building = await Repo.buildingRepository.save(Building(name: "默认"));
      for (final legacyFloor in floors) {
        var floor = await Repo.floorRepository.save(Floor(
            buildingId: building.id!,
            name: legacyFloor.name,
            sort: legacyFloor.sort));
        for (final legacyRoom in legacyFloor.rooms) {
          var room = await Repo.roomRepository.save(Room(
              floorId: floor.id!,
              name: legacyRoom.name,
              sort: legacyRoom.sort,
              rent: legacyRoom.fee.rent,
              electFee: legacyRoom.fee.electFee,
              waterFee: legacyRoom.fee.waterFee,
              leastMarkDate: legacyRoom.lastSelectedDay));
          var optFees = legacyRoom.optionFees
            .where((element) => element.name != null)
              .map((e) =>
                  RoomOption(roomId: room.id!, name: e.name!, fee: e.fee))
              .toList();
          await Repo.roomRepository.saveOptFees(room.id!, optFees);

          for (final legacyRoomDay in legacyRoom.roomDays) {
            await Repo.roomRepository.saveDay(RoomDay(
                roomId: room.id!,
                date: Util.normalizeDate(legacyRoomDay.date),
                elect: legacyRoomDay.elect.toDouble(),
                water: legacyRoomDay.water.toDouble()));
          }

          for (final legacyFeeSnapshot in legacyRoom.feeSnapshot) {
            await Repo.roomRepository.saveSnapshot(RoomSnapshotRecord(
                RoomSnapshot(
                    roomId: room.id!,
                    snapshotStartDate: legacyFeeSnapshot.date,
                    snapshotEndDate: legacyFeeSnapshot.date,
                    rent: legacyFeeSnapshot.rent,
                  elect: legacyFeeSnapshot.electAmount,
                  water: legacyFeeSnapshot.waterAmount,
                  electFee: legacyFeeSnapshot.electFee,
                  waterFee: legacyFeeSnapshot.waterFee,
                  totalAmount: legacyFeeSnapshot.total
                ),
                (legacyFeeSnapshot.items ?? [])
                    .map((e) => RoomSnapshotItem(
                        roomId: room.id!,
                        snapshotId: -1,
                        name: e.name,
                        desc: e.desc,
                        fee: e.fee))
                    .toList()));
          }
        }
      }
    });

    App.setCurrentVersion();
  }
}

class RebuildModel extends ChangeNotifier{

  Rebuild _rebuild=Rebuild(SharedPreferencesKv());

  bool _shouldRebuildVer2(){
    return App.dataVersion<Ver("3.0.0");
  }

  Future<RebuildModel> init() async{
    if(!_shouldRebuildVer2()){
      return this;
    }
    await _rebuild.start();
    return this;
  }

}