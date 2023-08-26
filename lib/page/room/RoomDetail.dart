import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/component/InitializingPage.dart';
import 'package:hermes/component/InitializingWidget.dart';
import 'package:hermes/component/LevitationBlock.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/model/Data.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/page/room/FeeItemDataTable.dart';
import 'package:hermes/page/room/Model.dart';
import 'package:hermes/page/room/RoomDayMarkerForm.dart';
import 'package:hermes/page/room/RoomFeeForm.dart';
import 'package:hermes/page/room/RoomSanpshotsList.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toast/toast.dart';

class RoomDetail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RoomDetailState();
  }
}

class RoomDetailState extends HermesState<RoomDetail> {
  GlobalKey _resultBlockKey = GlobalKey();
  double _fontSize = 15;

  void _captureContent(RoomModel model) async {

    var status = await Permission.storage.request();
    if (!status.isGranted) {
      return null;
    }
    // Permission
    RenderRepaintBoundary? boundary = _resultBlockKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    var image = await boundary?.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image?.toByteData(format: ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    model.capturePng(pngBytes!);
  }

  Future<void> _enterSnapshotPage(RoomModel model) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => ChangeNotifierProvider(
          create: (create) => RoomSnapshotModel(model.id),
          child: Scaffold(
              appBar: AppBar(
                title: Text("${model.title ?? ""} 记录"),
              ),
              body: RoomSnapshotList()),
        ),
      ),
    );
  }

  void _enterFeeForm(RoomModel model) async {
    RoomWithOptFee room = model.room!;
    bool? submit = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => ChangeNotifierProvider(
            create: (ctx) => RoomFeeFormModel(room.room, room.optFee),
            child: RoomFeeForm(),
          ),
        ));
    if (submit ?? false) {
      model.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    var param = (ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>);
    Printer.printMapJsonLog(param);
    var id = param["roomId"] as int;
    var name = param["name"] as String?;
    return FutureProvider<RoomModel?>(
      create: (e) => RoomModel(id).init(),
      catchError: (ctx, e) {
        Printer.error(e);
        Toast.show("获取数据时发生错误");
        Navigator.pop(ctx);
        return null;
      },
      initialData: null,
      child: Consumer<RoomModel?>(
        builder: (ctx, value, child) {
          return InitializingPage(
              title: Text(name??"加载中"),
              initialized: value != null,
              loadingText: Text("获取数据中..."),
              builder: () {
                return ChangeNotifierProvider.value(
                  value: value!,
                  child: Consumer<RoomModel>(
                    builder: (ctx, model, child) {
                      return Scaffold(
                          appBar: AppBar(
                            title: Text(model.title ?? "套间"),
                            actions: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.screen_share),
                                  onPressed: () => _captureContent(model)),
                              IconButton(
                                  icon: Icon(Icons.list),
                                  onPressed: () => _enterSnapshotPage(model)),
                            ],
                          ),
                          body: GestureDetector(
                            onTap: () => FocusScope.of(context).unfocus(),
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  _basicFee(model),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _roomDaysMarker(model),
                                  Slider(
                                    value: _fontSize,
                                    max: 20,
                                    min: 5,
                                    activeColor: Colors.blue,
                                    onChanged: (double val) {
                                      _fontSize = val;
                                      model.flush();
                                    },
                                  ),
                                  _ResultBlock(
                                    resultBlockKey: _resultBlockKey,
                                    fontSize: _fontSize,
                                    result: model.calculateResult(),
                                    doSave: (result) {
                                      return model.saveFeeSnapshot(result);
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ));
                    },
                  ),
                );
              });
        },
      ),
    );
  }

  Widget _feeField(String name, double fee, {String unit = "元"}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      // direction: Axis.horizontal,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 170, maxWidth: 170),
          child: Text(
            name,
            overflow: TextOverflow.fade,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
            child: Container(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            fee.toString(),
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        )),
        Text(
          unit,
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget basicDivider() {
    return Divider(
      height: 5,
      indent: 0,
    );
  }

  Widget _basicFee(RoomModel model) {
    var room = model.room;
    Printer.info(room);
    return LevitationContainer(
        child: Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "套间费用",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _enterFeeForm(model);
                        },
                        label: Text("修改费用"),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.lightBlue.shade100.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(-4, -4), // changes position of shadow
                        ),
                        BoxShadow(
                          color: Colors.limeAccent.shade100.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(4, 4), // changes position of shadow
                        ),
                      ],
                      border: Border(
                        left: BorderSide(
                            color: Colors.lightBlue.withOpacity(0.5)),
                        top: BorderSide(
                            color: Colors.lightBlue.withOpacity(0.5)),
                        right: BorderSide(
                            color: Colors.limeAccent.withOpacity(0.5)),
                        bottom: BorderSide(
                            color: Colors.limeAccent.withOpacity(0.5)),
                      )),
                  child: Column(
                    children: [
                      _feeField("租金", room?.room.rent ?? 0, unit: "元"),
                      basicDivider(),
                      _feeField("电费", room?.room.electFee ?? 1, unit: "(元/度)"),
                      basicDivider(),
                      _feeField("水费", room?.room.waterFee ?? 0, unit: "(元/度)"),
                    ],
                  ),
                ),
                Column(
                  children: [
                    for (RoomOption opt in room?.optFee ?? [])
                      Column(
                        children: [
                          basicDivider(),
                          _feeField(opt.name, opt.fee ?? 0, unit: "元"),
                        ],
                      )
                  ],
                ),
                basicDivider(),
              ],
            )));
  }

  Widget _roomDaysMarker(RoomModel model) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.5),
        child: Container(
          child: Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChangeNotifierProvider.value(
                  value: model.mainBlock,
                  child: RoomDayMarker(),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                        height: 20,
                        child: VerticalDivider(
                          color: Colors.black,
                          width: 20,
                          thickness: 2,
                        )),
                    Container(
                        height: 20,
                        child: VerticalDivider(
                          color: Colors.black,
                          width: 20,
                          thickness: 2,
                        )),
                  ],
                ),
                SizedBox(height: 5),
                ChangeNotifierProvider.value(
                  value: model.subBlock,
                  child: RoomDayMarker(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultBlock extends StatelessWidget {
  Key resultBlockKey;
  double fontSize;
  FeeResult result;
  Future<void> Function(FeeResult) doSave;

  _ResultBlock(
      {required this.resultBlockKey,
      required this.fontSize,
      required this.result,
      required this.doSave});

  Widget text(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mainColor = Colors.white;
    ToastContext().init(context);
    return LevitationContainer(
        padding: EdgeInsets.all(0),
        child: Container(
          color: mainColor,
          child: Column(
            children: [
              RepaintBoundary(
                key: resultBlockKey,
                child: Container(
                    color: mainColor,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.lightbulb,
                                  color: Colors.yellow.shade800,
                                ),
                                text("电费: "),
                                text("${result.elect} 元/度"),
                              ],
                            )),
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.fiber_manual_record,
                                  color: Colors.blue.shade800,
                                ),
                                text("水费: "),
                                text("${result.water} 元/度"),
                              ],
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: text("${result.name}"),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: text("${Util.formatDay(result.mainDate)}"),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: FeeItemDataTable(
                            rowHeight: 60,
                            items: result.items,
                            fontSize: fontSize,
                          ),
                        )
                      ],
                    )),
              ),
              ElevatedButton(
                onPressed: () async {
                  await doSave(result);
                  Toast.show("保存成功");
                },
                child: Text("保存"),
              ),
            ],
          ),
        ));
  }
}
