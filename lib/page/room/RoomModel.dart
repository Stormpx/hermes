
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hermes/App.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/model/FeeResult.dart';
import 'package:hermes/page/floor/Floor.dart';
import 'package:hermes/page/roomlist/Room.dart';
import 'package:hermes/page/snapshot/RoomSanpshotPage.dart';
import 'package:hermes/page/snapshot/RoomSnapshotModel.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class RoomModel extends ChangeNotifier{
  static final String DATE_KEY=":date:";
  static final String FEE_KEY=":fee";
  static final String OPTION_KEY=":option:fee";
  static final String LAST_SELECT_KEY="_LAST_SELECT";


  SharedPreferences _preferences;

  bool initialized=false;

  CalendarController calendarController = CalendarController();


  TextEditingController rentController= TextEditingController();
  TextEditingController electFeeController= TextEditingController();
  TextEditingController waterFeeController= TextEditingController();


  TextEditingController leftElectController= TextEditingController();
  TextEditingController leftWaterController= TextEditingController();

  TextEditingController rightElectController= TextEditingController();
  TextEditingController rightWaterController= TextEditingController();

  Floor floor;
  Room room;

  Fee fee;
  OptionFeeList optionFeeList;

  bool selectLeft=false;
  RoomDay left;
  RoomDay right;

  Map<DateTime,List> events={};

  RoomModel(this.floor,this.room){
    _init();
  }

  /// 初始化
  void _init() async{
    _preferences=App.sharedPreferences;

    var now=DateTime.now();

    _changeLeft(get(now));

    _changeRight(get(now));

    //固定收费项
    var str=_preferences.getString("${room.name}$FEE_KEY");
    if(str!=null) {
      this.fee = Fee.fromJson(jsonDecode(str));
      electFeeController.text=this.fee.electFee?.toString();
      waterFeeController.text=this.fee.waterFee?.toString();
      rentController.text=this.fee.rent?.toString();
    }
    //最后保存日期
    var date=_preferences.getString("${room.name}$LAST_SELECT_KEY");
    if(date!=null) {
      _changeLeft(get(DateFormat('yyyy-MM-dd').parse(date)));
    }
    //自定义收费项
    var optionList=_preferences.getString("${room.name}$OPTION_KEY");
    this.optionFeeList=optionList!=null?OptionFeeList.fromJson(jsonDecode(optionList)):OptionFeeList(List());

    //加载抄表日期
    onVisibleDaysChanged(Util.firstDayOfMonth(now), Util.lastDayOfMonth(now), CalendarFormat.month);
  
    initialized=true;

    notifyListeners();

  }

  void addOptionFee(){
      optionFeeList.add(OptionFee());
      notifyListeners();
  }


  void removeOptionFee(int index){
    optionFeeList.remove(index);
    notifyListeners();
  }


  void onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format){
      var du=Duration(days: 1);
      while(first.isBefore(last)){
        var d=get(first);
        if(d.water!=0||d.elect!=0){
          events.update(d.date,
                  (value) => [d.elect],
              ifAbsent: () => [d.elect]);
        }else{
          events.remove(d.date);
        }
        first=first.add(du);
      }
  }

  ///改变左边日期
  void _changeLeft(RoomDay rd){
    left=rd;
    leftElectController.text=left.elect.toString();
    leftWaterController.text=left.water.toString();
  }

  ///改变右边日期
  void _changeRight(RoomDay rd){
    right=rd;
    rightElectController.text=right.elect.toString();
    rightWaterController.text=right.water.toString();
  }

  ///获取日期数据
  RoomDay get(DateTime date) {
    var str=_preferences.getString("${room.name}$DATE_KEY${DateFormat('yyyy-MM-dd').format(date)}");
    if(str==null)
      return RoomDay(
        date: date,
        elect: 0,
        water: 0
      );
    return RoomDay.fromJson(jsonDecode(str));
  }


  void selectDate(DateTime dateTime){
    if(selectLeft){
      _changeLeft(get(dateTime));
      if(left.date.isAfter(right.date)){
        _changeRight(left);
      }
    }else{
      _changeRight(get(dateTime));
      if(left.date.isAfter(right.date)){
        _changeLeft(right);
      }
    }


    notifyListeners();
  }

  void saveDate(BuildContext context,bool left) async{
    RoomDay rd;

    if(left){
      rd=this.left;
    }else{
      rd=this.right;
    }
    FocusScope.of(context).unfocus();

    await _preferences.setString("${room.name}$DATE_KEY${rd.dateStr()}", jsonEncode(rd));
    await _preferences.setString("${room.name}$LAST_SELECT_KEY", rd.dateStr());

    //日历做个标记
    if(rd.elect!=0||rd.water!=0){
      events.update(rd.date,
              (value) => [rd.elect],
          ifAbsent: () => [rd.elect]);
    }

    Toast.show("保存成功", context,gravity: Toast.BOTTOM);

  }

  String leftTime(){
    return left.dateStr();
  }

  String rightTime(){
    return right.dateStr();
  }

  /// 保存费用
  void saveFee(BuildContext context) async{
    double rent=double.tryParse(rentController.text);
    double ef=double.tryParse(electFeeController.text);
    double wf=double.tryParse(waterFeeController.text);
    if(rent==null||ef==null||wf==null){
      return ;
    }
    var f=Fee(
        rent: rent,
        electFee: ef,
        waterFee: wf
    );


    this.fee=f;

    FocusScope.of(context).unfocus();
    //保存固定收费项
    await _preferences.setString("${room.name}$FEE_KEY", jsonEncode(f));

    //保存自定义收费项
    var option=optionFeeList.toJson();
    await _preferences.setString("${room.name}$OPTION_KEY", jsonEncode(option));

    Toast.show("保存成功", context,gravity: Toast.BOTTOM);

    notifyListeners();
  }

  void selected(bool left){
    selectLeft=left;
    notifyListeners();
  }


  void reCalculate(String value) {
    print("caclulate");


    left.elect=int.parse(leftElectController.text);
    left.water=int.parse(leftWaterController.text);

    right.elect=int.parse(rightElectController.text);
    right.water=int.parse(rightWaterController.text);


    notifyListeners();

  }

  /// 所有收费项加起来计算结果
  FeeSnapshot calculateResult(){
    if(fee==null){
      return null;
    }
    double rent = fee.rent ?? 0;
    double electFee = fee.electFee ?? 0;
    double waterFee = fee.waterFee ?? 0;

    int rightElect = right.elect;
    int leftElect = left.elect;

    int rightWater = right.water;
    int leftWater = left.water;

    int usedElect = rightElect - leftElect;
    int usedWater = rightWater - leftWater;

    //电费
    double eFee = usedElect * electFee;
    //水费
    double wFee = usedWater * waterFee;

    double total = rent+eFee+wFee;

    var list=[
      FeeItem.get("电费","$rightElect - $leftElect = $usedElect 度\n$usedElect * $electFee = ${eFee.toStringAsFixed(2)} 元",eFee),
      FeeItem.get("水费","$rightWater - $leftWater = $usedWater 度\n$usedWater * $waterFee = ${wFee.toStringAsFixed(2)} 元",eFee),
      //租金
      FeeItem.get("租金",null,rent),
    ];

    optionFeeList.availableList.forEach((element) {
      total += element.fee;
      list.add(FeeItem.get(element.name, null, element.fee));
    });

    list.add(FeeItem.get("总收费", null, total));
    var fr= FeeSnapshot(
      date: right.date,
      electFee: electFee,
      waterFee: waterFee,
      rent: rent,
      electAmount: usedElect.toDouble(),
      waterAmount: usedWater.toDouble(),
      total: total,
      items: list,
    );

    return fr;
  }




  Future<void> saveFeeSnapshot(BuildContext context,FeeSnapshot feeSnapshot) async {

    await _preferences.setString("${room.name}${FeeSnapshot.room_fee_snapshot_key}${Util.formatDay(feeSnapshot.date)}",
        jsonEncode(feeSnapshot.toJson()));

    Toast.show("保存成功", context,gravity: Toast.BOTTOM);

  }

  void showSnapshot(BuildContext context) async{
    await Navigator.push(context, MaterialPageRoute(
        builder: (c)=>ChangeNotifierProvider(
          create: (c)=>RoomSnapshotModel(room),
          child: RoomSnapshotPage(),
        )
    ));
  }

  void capturePng(Uint8List pngBytes) async{
    var status=await Permission.storage.request();
    if(!status.isGranted){
      return null;
    }
    var dir = App.dir(dir:"screenshot/");
    if(! await dir.exists())
      await dir.create(recursive: true);
    var file=File("${dir.path}${Uuid().v4()}.png");
    await file.writeAsBytes(pngBytes);
    Share.shareFiles(
      [file.path],
      text: "截图"
    );
  }


}

class RoomDay{
  DateTime date;
  int elect;
  int water;


  RoomDay({this.date, this.elect, this.water});

  factory RoomDay.fromJson(Map<String, dynamic> json) {

    return RoomDay(
        date: DateTime.parse(json['date'] as String),
        elect: json['elect'] as int,
        water: json['water'] as int
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'date': date.toString(),
        'elect': elect,
        'water': water
      };


  String dateStr(){
    return DateFormat('yyyy-MM-dd').format(date);
  }
  

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomDay &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;

  @override
  String toString() {
    return 'RoomDay{date: $date, elect: $elect, water: $water}';
  }
}

class Fee{
  double rent;
  double electFee;
  double waterFee;


  Fee({this.rent,this.electFee, this.waterFee});

  factory Fee.fromJson(Map<String, dynamic> json) {

    return Fee(
        rent: json['rent'] as double,
        electFee: json['electFee'] as double,
        waterFee: json['waterFee'] as double,
    );
  }


  Map<String, dynamic> toJson() =>
      {
        'rent': rent,
        'electFee': electFee,
        'waterFee': waterFee,
      };
}


class OptionFeeList{
  List<OptionFee> _list;

  List<OptionFee> get list => _list;

  List<OptionFee> get availableList => _list.where((element) => element.name!=null&&element.name.isNotEmpty).toList();

  OptionFeeList(this._list);

  factory OptionFeeList.fromJson(List<dynamic> json) {
      var li=json.map((e) => OptionFee.fromJson(e)).toList();
      return OptionFeeList(li);
  }


  List<dynamic> toJson() {
    return availableList
        .map((e) => e.toJson())
        .toList();
  }


  int add(OptionFee option){
    _list.add(option);
    return _list.length;

  }

  void remove(int index){
    _list.removeAt(index);
  }

}


class OptionFee{
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _feeTextController = TextEditingController();

  String name;
  double fee;


  TextEditingController get nameTextController => _nameTextController;

  TextEditingController get feeTextController => _feeTextController;


  OptionFee({this.name,this.fee}){
    _feeTextController.addListener(() {
        fee=double.tryParse(_feeTextController.text)??0;
    });
    _nameTextController.addListener(() {
        name=_nameTextController.text;
    });
    _nameTextController.text=name?.toString();
    _feeTextController.text=fee?.toString();
  }

  factory OptionFee.fromJson(Map<String, dynamic> json) {
    return OptionFee(
      name: json['name'] as String,
      fee: json['fee'] as double,
    );
  }


  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'fee': fee,
      };

}