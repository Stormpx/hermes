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

class MarkerBlock extends ChangeNotifier {
  final RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
  RoomModel? roomModel;

  final TextEditingController electController = TextEditingController();
  final TextEditingController waterController = TextEditingController();

  DateTime? lastDay;
  DateTime focusedDay = Util.normalizeDate(DateTime.now());
  DateTime selectedDay = Util.normalizeDate(DateTime.now());

  double get elect => double.tryParse(electController.text) ?? 0;

  double get water => double.tryParse(waterController.text) ?? 0;

  void set days(DateTime date) {
    this.focusedDay = date;
    this.selectedDay = date;
  }

  set elect(double value) {
    electController.text = value.toString().replaceAll(regex, '');
  }

  set water(double value) {
    waterController.text = value.toString().replaceAll(regex, '');
  }

  void setValue(double elect, double water) {
    this.elect = elect;
    this.water = water;
    notifyListeners();
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
  }

  @override
  String toString() {
    return 'MarkerBlock{selectedDay: $selectedDay, elect: $elect, water: $water}';
  }
}

class RoomModel extends ChangeNotifier {
  MarkerBlock mainBlock = MarkerBlock();
  MarkerBlock subBlock = MarkerBlock();

  int id;
  RoomWithOptFee? room;

  Map<DateTime, RoomDay> days = {};

  String? get title => room?.room.name ?? null;

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
      this.days[Util.normalizeDate(element.date)] = element;
    });
  }

  RoomDay? getRoomDay(DateTime date) {
    return days[date];
  }

  Future<void> loadRoomDay(MarkerBlock block) async {
    var roomDay = (await Repo.roomRepository
                .findDaysById(id, block.selectedDay, block.selectedDay))
            .firstOrNull ??
        RoomDay(roomId: id, date: block.selectedDay, elect: 0, water: 0);
    block.setValue(roomDay.elect ?? 0, roomDay.water ?? 0);

    if (block.selectedDay.isBefore(subBlock.selectedDay)) {
      subBlock.days = block.selectedDay;
      subBlock.setValue(block.elect, block.water);
    }
    if (block.selectedDay.isAfter(mainBlock.selectedDay)) {
      mainBlock.days = block.selectedDay;
      mainBlock.setValue(block.elect, block.water);
    }

    notifyListeners();
  }

  Future<void> saveRoomDay(MarkerBlock block) async {
    var roomUpdated = await Repo.roomRepository.runOnScope(() async {
      var roomDay = (await Repo.roomRepository
                  .findDaysById(id, block.selectedDay, block.selectedDay))
              .firstOrNull
              ?.copyWith(
                  elect: Value(block.elect), water: Value(block.water)) ??
          RoomDay(
              roomId: id,
              date: Util.normalizeDate(block.selectedDay),
              elect: block.elect,
              water: block.water);
      roomDay = await Repo.roomRepository.saveDay(roomDay);

      days[roomDay.date] = roomDay;

      if (block != mainBlock &&
          Util.isSameDay(block.selectedDay, mainBlock.selectedDay)) {
        mainBlock.setValue(block.elect, block.water);
      }

      if (block != subBlock &&
          Util.isSameDay(block.selectedDay, subBlock.selectedDay)) {
        subBlock.setValue(block.elect, block.water);
      }

      var r = room!.room;
      if (r.leastMarkDate?.isBefore(roomDay.date) ?? true) {
        r = await Repo.roomRepository
            .save(r.copyWith(leastMarkDate: Value(roomDay.date)));
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
    double mainElect = mainBlock.elect;
    double subElect = subBlock.elect;

    double mainWater = mainBlock.water;
    double subWater = subBlock.water;

    double usedElect = mainElect - subElect;
    double usedWater = mainWater - subWater;

    //电费
    double electAmount = usedElect * electFee;
    //水费
    double waterAmount = usedWater * waterFee;

    double totalAmount = rent + electAmount + waterAmount;

    var list = [
      FeeItem.get(
          "电费",
          "$mainElect - $subElect = $usedElect 度\n$usedElect * $electFee = ${electAmount.toStringAsFixed(2)} 元",
          electAmount),
      FeeItem.get(
          "水费",
          "$mainWater - $subWater = $usedWater 度\n$usedWater * $waterFee = ${waterAmount.toStringAsFixed(2)} 元",
          waterAmount),
      //租金
      FeeItem.get("租金", null, rent),
    ];

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
      usedElect: usedElect,
      usedWater: usedWater,
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
    var rent = double.tryParse(val['rent'] as String) ?? 0;
    var elect = double.tryParse(val['elect'] as String) ?? 0;
    var water = double.tryParse(val['water'] as String) ?? 0;

    room = room.copyWith(
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
      : records
          .map((e) => e.snapshot.totalAmount)
          .map((e) => e ?? 0)
          .reduce(min)
          .roundToDouble();

  double get maximumTotal =>records.isEmpty
      ? 0
      : records
      .map((e) => e.snapshot.totalAmount)
      .map((e) => e ?? 0)
      .reduce(max)
      .roundToDouble();

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
