import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/App.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/model/Data.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/model/Repository.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:expressions/expressions.dart' as exp;

final RegExp regex = RegExp(r'([.]*0)(?!.*\d)');

double _evalValue(String text){
  var expr = exp.Expression.tryParse(text);
  if(expr==null){
    return 0;
  }
  var r= exp.ExpressionEvaluator().eval(expr, {});
  return r is int ? r.toDouble():r is double? Util.round2(r, 2):0;
}

class RoomMeter{
  double elect;
  double water;

  RoomMeter(this.elect, this.water);

}

class RoomMeterController{
  final TextEditingController electController = TextEditingController();
  final TextEditingController waterController = TextEditingController();

  double get elect => _evalValue(electController.text);
  double get water => _evalValue(waterController.text);

  set elect(double value) {
    electController.text = value.toString().replaceAll(regex, '');
  }
  set water(double value) {
    waterController.text = value.toString().replaceAll(regex, '');
  }
  void setValue(double elect, double water) {
    this.elect = elect;
    this.water = water;
  }

  @override
  String toString() {
    return 'RoomMeterController{elect: $elect, water: $water}';
  }
}


class MarkerBlock extends ChangeNotifier {
  RoomModel? roomModel;

  DateTime? lastDay;
  DateTime focusedDay = Util.normalizeDate(DateTime.now());
  DateTime selectedDay = Util.normalizeDate(DateTime.now());

  final Map<int,RoomMeterController> roomMeters = {};

  int get meters=> roomModel?.meters??1;

  int get electMeters => roomModel?.electMeters??1;

  int get waterMeters => roomModel?.waterMeters??1;

  RoomMeterController meterController(int seq){
    var controller = roomMeters[seq];
    if(controller==null){
      roomMeters[seq] = RoomMeterController();
      controller = roomMeters[seq]!;
    }
    return controller;
  }

  double elect(int seq){
    return roomMeters[seq]?.elect??0;
  }

  double water(int seq){
    return roomMeters[seq]?.water??0;
  }

  void set days(DateTime date) {
    this.focusedDay = date;
    this.selectedDay = date;
  }

  void setValueBySeq(int seq,double elect, double water) {
    var roomMeterController = roomMeters.putIfAbsent(seq, ()=>RoomMeterController());
    roomMeterController.elect = elect;
    roomMeterController.water = water;
    notifyListeners();
  }

  void _setBlockValue(MarkerBlock block){
    block.roomMeters.forEach((seq,meter){
      if(roomMeters[seq]==null) {
        roomMeters[seq] = RoomMeterController();
      }
      roomMeters[seq]!.elect = meter.elect;
      roomMeters[seq]!.water = meter.water;
    });
  }

  void setBlockValue(MarkerBlock block){
    if(this==block){
      return;
    }
    _setBlockValue(block);
  }


  Future<void> loadEvents(DateTime date) async {
    focusedDay = date;
    await roomModel?.loadEvents(date);
    notifyListeners();
  }

  Future<void> loadDay(DateTime date) async {
    selectedDay = Util.normalizeDate(date);
    await roomModel?.loadRoomDay(this);
  }

  Future<void> submit() async {
    await roomModel?.saveRoomDay(this);
    _setBlockValue(this);
  }

  @override
  String toString() {
    return 'MarkerBlock{selectedDay: $selectedDay}';
  }
}

class RoomModel extends ChangeNotifier {
  MarkerBlock mainBlock = MarkerBlock();
  MarkerBlock subBlock = MarkerBlock();

  int id;
  RoomWithOptFee? room;

  Set<DateTime> _markerDays= Set();

  String? get title => room?.room.name ?? null;

  int get meters => max(room?.room.electMeters??1,room?.room.waterMeters??1);

  int get electMeters => room?.room.electMeters??1;

  int get waterMeters => room?.room.waterMeters??1;

  RoomModel(this.id) {
    mainBlock.roomModel = this;
    subBlock.roomModel = this;
  }

  Future<RoomModel> init() async {
    room = await Repo.roomRepository.findRoom(id);

    if (room!.room.leastMarkDate != null) {
      // mainBlock.selectedDay = Util.normalizeDate(room!.room.leastMarkDate!);
      subBlock.selectedDay = Util.normalizeDate(room!.room.leastMarkDate!);
      // bottomBlock.lastDay=bottomBlock.selectedDay;
    }
    await loadEvents(mainBlock.selectedDay);
    await loadEvents(subBlock.selectedDay);
    await loadRoomDay(mainBlock);
    await loadRoomDay(subBlock);

    return this;
  }

  void reload() async {
    room = await Repo.roomRepository.findRoom(id);
    notifyListeners();
  }

  Future<void> loadEvents(DateTime date) async {
    var start = Util.firstDayOfMonth(date);
    var end = Util.lastDayOfMonth(date);
    var days = await Repo.roomRepository.findDaysById(id, start, end);
    Printer.info(days);
    days.forEach((element) {
      _markerDays.add(Util.normalizeDate(element.date));
    });
  }

  bool isDayMarked(DateTime date){
    return _markerDays.contains(date);
  }

  Future<void> loadRoomDay(MarkerBlock block) async {
    var roomDays = (await Repo.roomRepository.findDaysById(id, block.selectedDay, block.selectedDay));
    if(roomDays.isEmpty){
      roomDays = [RoomDay(roomId: id, date: block.selectedDay,seq: 1, elect: 0, water: 0)];
    }
    var roomMeters = { for (var roomDay in roomDays) roomDay.seq: roomDay };

    for (int seq = 1; seq <= this.meters; seq++) {
      var meter = roomMeters[seq];
      roomDays.forEach((roomDay)=>block.setValueBySeq(seq,meter?.elect ?? 0, meter?.water ?? 0));
    }

    if (block.selectedDay.isBefore(subBlock.selectedDay)) {
      subBlock.days = block.selectedDay;
      subBlock.setBlockValue(block);
    }
    if (block.selectedDay.isAfter(mainBlock.selectedDay)) {
      mainBlock.days = block.selectedDay;
      mainBlock.setBlockValue(block);
    }

    notifyListeners();
  }

  Future<void> saveRoomDay(MarkerBlock block) async {
    var roomUpdated = await Repo.roomRepository.runOnScope(() async {
      var roomDays = (await Repo.roomRepository.findDaysById(id, block.selectedDay, block.selectedDay));

      var roomMeters = { for (var roomDay in roomDays) roomDay.seq: roomDay };

      for (int seq = 1; seq <= this.meters; seq++) {
        var meter = roomMeters[seq];
        var elect = block.roomMeters[seq]?.elect??0;
        var water = block.roomMeters[seq]?.water??0;
        var roomDay = meter?.copyWith(elect: Value(elect), water: Value(water)) ??
            RoomDay(roomId: id, date: Util.normalizeDate(block.selectedDay),
                seq: seq, elect: elect, water: water);
        roomDay = await Repo.roomRepository.saveDay(roomDay);
        _markerDays.add(Util.normalizeDate(roomDay.date));
      }

      if (block != mainBlock && Util.isSameDay(block.selectedDay, mainBlock.selectedDay)) {
        mainBlock.setBlockValue(block);
      }

      if (block != subBlock && Util.isSameDay(block.selectedDay, subBlock.selectedDay)) {
        subBlock.setBlockValue(block);
      }

      var r = room!.room;
      if (r.leastMarkDate?.isBefore(block.selectedDay) ?? true) {
        r = await Repo.roomRepository
            .save(r.copyWith(leastMarkDate: Value(block.selectedDay)));
        return true;
      } else {
        return false;
      }
    });

    if (roomUpdated) {
      reload();
    } else {
      notifyListeners();
    }
  }

  FeeResult calculateResult() {
    double rent = room?.room.rent ?? 0;
    double electFee = room?.room.electFee ?? 0;
    double waterFee = room?.room.waterFee ?? 0;

    int electMeters = room?.room.electMeters??1;
    int waterMeters = room?.room.waterMeters??1;

    double totalUsedElect = 0;
    double totalUsedWater = 0;
    double totalAmount = rent;

    var list = [FeeItem.get("租金", null, rent),];

    for(int seq=1;seq<=electMeters;seq++){
      double mainElect = mainBlock.elect(seq);
      double subElect = subBlock.elect(seq);
      double usedElect = mainBlock.elect(seq) - subBlock.elect(seq);
      //电费
      double amount = usedElect * electFee;
      list.add(
          FeeItem.get(
            "电表$seq",
            "$mainElect - $subElect = $usedElect 度\n$usedElect * $electFee = ${amount.toStringAsFixed(2)} 元",
              amount)
      );
      totalAmount+=amount;
      totalUsedElect+=usedElect;
    }

    for(int seq=1;seq<=waterMeters;seq++){
      double mainWater = mainBlock.water(seq);
      double subWater = subBlock.water(seq);
      double usedWater = mainWater - subWater;
      //电费
      double amount = usedWater * waterFee;
      list.add(
        FeeItem.get(
            "水表$seq",
            "$mainWater - $subWater = $usedWater 度\n$usedWater * $waterFee = ${amount.toStringAsFixed(2)} 元",
            amount),
      );
      totalAmount+=amount;
      totalUsedWater=usedWater;
    }


    List<RoomOption> opts = room?.optFee ?? [];
    opts.forEach((opt) {
      totalAmount += opt.fee ?? 0;
      list.add(FeeItem.get(opt.name, null, opt.fee ?? 0));
    });
    list.add(FeeItem.get("总收费", null, totalAmount));

    return FeeResult(
      name: title ?? "",
      mainDate: mainBlock.selectedDay,
      subDate: subBlock.selectedDay,
      rent: rent,
      elect: electFee,
      water: waterFee,
      usedElect: totalUsedElect,
      usedWater: totalUsedWater,
      totalAmount: totalAmount,
      items: list,
    );
  }

  Future<void> saveFeeSnapshot(FeeResult result) async {
    var snapshot = RoomSnapshot(
        roomId: id,
        snapshotStartDate: result.mainDate,
        snapshotEndDate: result.subDate,
        rent: result.rent,
        electFee: result.elect,
        waterFee: result.water,
        elect: result.usedElect,
        water: result.usedWater,
        totalAmount: result.totalAmount);
    var items = result.items
        .map((e) => RoomSnapshotItem(
            roomId: id, snapshotId: -1, name: e.name, desc: e.desc, fee: e.fee))
        .toList();

    await Repo.roomRepository.runOnScope(() =>
        Repo.roomRepository.saveSnapshot(RoomSnapshotRecord(snapshot, items)));
  }

  void flush() {
    notifyListeners();
  }

  void capturePng(Uint8List pngBytes) async {
    var dir = App.dir(dir: "screenshot/");
    if (!await dir.exists()) await dir.create(recursive: true);
    var file = File("${dir.path}${Uuid().v4()}.png");
    file = await file.writeAsBytes(pngBytes, flush: true);
    Printer.info(file.path);
    Share.shareXFiles([XFile(file.path)], text: "截图");
  }
}

class FeeResult {
  String name;
  DateTime mainDate;
  DateTime subDate;
  double rent;
  double elect;
  double water;
  double usedElect;
  double usedWater;
  double totalAmount;
  List<FeeItem> items;

  FeeResult(
      {required this.name,
      required this.mainDate,
      required this.subDate,
      required this.rent,
      required this.elect,
      required this.water,
      required this.usedElect,
      required this.usedWater,
      required this.totalAmount,
      required this.items}) {}

  @override
  String toString() {
    return 'FeeResult{name: $name, mainDate: $mainDate, subDate: $subDate, rent: $rent, elect: $elect, water: $water, totalAmount: $totalAmount, items: $items}';
  }
}

class FeeItem {
  String name;
  String? desc;
  double fee;

  FeeItem({required this.name, this.desc, this.fee = 0}) {}

  factory FeeItem.fromSnapshotItem(RoomSnapshotItem item) {
    return FeeItem(name: item.name, desc: item.desc, fee: item.fee ?? 0);
  }

  factory FeeItem.get(String name, String? desc, double fee) {
    return FeeItem(name: name, desc: desc, fee: fee);
  }

  factory FeeItem.fromJson(Map<String, dynamic> json) {
    return FeeItem(
        name: json['name'] as String,
        desc: json['desc'] as String?,
        fee: (json['fee'] as double?) ?? 0);
  }
}

class RoomFeeFormModel extends ChangeNotifier {
  Room room;
  List<RoomOption> optFees;

  RoomFeeFormModel(this.room, this.optFees);

  Map<String, dynamic> initFormValue() {
    Map<String, dynamic> value = {
      'electMeters': (room.electMeters ?? 1).toString(),
      'waterMeters': (room.waterMeters ?? 1).toString(),
      'rent': (room.rent ?? 0).toString(),
      'elect': (room.electFee ?? 0).toString(),
      'water': (room.waterFee ?? 0).toString(),
    };
    optFees.forEach((opt) {
      value[opt.name] = (opt.fee ?? 0).toString();
    });
    return value;
  }

  void addOpt(String name) {
    optFees.add(RoomOption(roomId: room.id!, name: name, fee: 0));
    notifyListeners();
  }

  void removeOpt(RoomOption opt) {
    optFees.remove(opt);
    notifyListeners();
  }

  Future<void> submit(Map<String, dynamic> val) async {
    Printer.info(val);
    var electMeters = int.tryParse(val['electMeters'])??0;
    var waterMeters = int.tryParse(val['waterMeters'])??0;
    var rent = double.tryParse(val['rent'] as String) ?? 0;
    var elect = double.tryParse(val['elect'] as String) ?? 0;
    var water = double.tryParse(val['water'] as String) ?? 0;

    room = room.copyWith(electMeters: Value(electMeters),waterMeters: Value(waterMeters),
        rent: Value(rent), electFee: Value(elect), waterFee: Value(water));

    optFees = optFees
        .map((e) =>
            e.copyWith(fee: Value(double.tryParse(val[e.name] as String) ?? 0)))
        .toList();
    await Repo.roomRepository.runOnScope(() async {
      room = await Repo.roomRepository.save(room);
      await Repo.roomRepository.saveOptFees(room.id!, optFees);
    });
  }

  void optReorder(int oldIndex, int newIndex) {
    // Printer.info("old:$oldIndex new:$newIndex");
    if (newIndex > oldIndex) {
      var optFee = optFees.elementAt(oldIndex);
      optFees.insert(newIndex, optFee);
      optFees.removeAt(oldIndex);
    } else {
      optFees.insert(newIndex, optFees.removeAt(oldIndex));
    }
    // notifyListeners();
  }
}

class RoomSnapshotModel extends ChangeNotifier {
  int id;
  List<RoomSnapshotRecord> records = [];

  RoomSnapshotModel(this.id) {
    _init();
  }

  double get minimumTotal => records.isEmpty
      ? 0
      : Util.round2(records
      .map((e) => e.snapshot.totalAmount)
      .map((e) => e ?? 0)
      .reduce(min), 2);

  double get maximumTotal =>records.isEmpty
      ? 0
      : Util.round2(records
      .map((e) => e.snapshot.totalAmount)
      .map((e) => e ?? 0)
      .reduce(max), 2);

  DateTime get minimumTime =>  records.isEmpty
      ? DateTime.utc(1999)
      : records
      .map((e) => e.snapshot.snapshotStartDate)
      .reduce((a,b)=>a.compareTo(b)>0?b:a);

  DateTime get maximumTime =>  records.isEmpty
      ? DateTime.utc(1999)
      : records
      .map((e) => e.snapshot.snapshotStartDate)
      .reduce((a,b)=>a.compareTo(b)>0?a:b);


  Future<void> _init() async {
    records = await Repo.roomRepository.findSnapshotByRoomId(id);
    Printer.info(records);
    notifyListeners();
  }

  Future<void> deleteRecord(RoomSnapshotRecord record) async {
    records.remove(record);
    if (record.snapshot.id != null) {
      var del = await Repo.roomRepository.runOnScope(
          () => Repo.roomRepository.delSnapshotById(record.snapshot.id!));
      Printer.info("del $record ${del ? "success" : "fail"}");
      notifyListeners();
    }
  }
}
