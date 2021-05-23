import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flukit/flukit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hermes/FeeItemDataTable.dart';
import 'package:hermes/GreatGradientButton.dart';
import 'package:hermes/InitializingWidget.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/page/room/RoomModel.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../FloatButton.dart';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  GlobalKey rootWidgetKey = GlobalKey();

  Uint8List _image=null;

  void _captureContent(RoomModel model) async{
    if(!model.isComputable())
      return;
    RenderRepaintBoundary boundary =
    rootWidgetKey.currentContext.findRenderObject();
    var image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    model.capturePng(pngBytes);

  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var roomModel = Provider.of<RoomModel>(context);

    return Scaffold(
//        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
          title: Text(roomModel.room.name),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.screen_share),
                onPressed: ()=>_captureContent(roomModel)),
            IconButton(icon: Icon(Icons.list),
                onPressed: ()=>roomModel.showSnapshot(context)),

          ],
        ),
        body: InitializingWidget(
          initialized: roomModel.initialized,
          loadingText: Text("获取数据中..."),
          builder: (){
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _feeWidget(),
                    _divider(),
                    _calendar(),
                    _divider(),
                    _dayWidget(),
                    _divider(),
                    _caclulateResultTestWidget()
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget _divider(){
    return Divider(
      height: 20.0,
      indent: 0,
      color: Colors.lightBlueAccent,
      thickness: 2,
    );
  }


  Widget _calendar(){
    var roomModel = Provider.of<RoomModel>(context);
    return TableCalendar(
      events: roomModel.events,
      calendarController: roomModel.calendarController,
      onVisibleDaysChanged: roomModel.onVisibleDaysChanged,
//                initialSelectedDay: roomModel.selectedDays(),
      initialCalendarFormat: CalendarFormat.month,
      availableGestures: AvailableGestures.horizontalSwipe,
      availableCalendarFormats: {
        CalendarFormat.month: 'Month',
      },
      locale: 'zh_CN',
      onDaySelected: (d, e,h) {
        roomModel.selectDate(d);
      },
      builders: CalendarBuilders(
        todayDayBuilder: (context, date, _) {
          return Container(
            alignment: Alignment.center,
//                      margin: const EdgeInsets.all(4.0),
//                      padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];
          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          return children;
        },
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    var roomModel = Provider.of<RoomModel>(context, listen: false);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: roomModel.calendarController.isSelected(date)
            ? Colors.brown[500]
            : roomModel.calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _feeWidget() {
    var roomModel = Provider.of<RoomModel>(context);
    List<Widget> list = [
      Container(
//              color: Colors.redAccent,
        child: Text(
          "长按这里保存费用",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      feeTextField(
          roomModel.rentController,
          "租金 元",
          Icon(
            Icons.attach_money,
            color: Colors.white,
          )),
      feeTextField(
          roomModel.electFeeController,
          "电费 元/度",
          Icon(
            Icons.atm,
            color: Colors.white,
          )),
      feeTextField(
          roomModel.waterFeeController,
          "水费 元/度",
          Icon(
            Icons.fiber_manual_record,
            color: Colors.white,
          )),
    ];

    var optionFeeList = roomModel.optionFeeList;
    for (int i = 0; i < optionFeeList.list.length; i++) {
      var optionFee = optionFeeList.list[i];
      list.add(optionFeeTextField(optionFee.nameTextController,
          optionFee.feeTextController, () => roomModel.removeOptionFee(i)));
    }

    list.add(Container(
      child: RaisedButton(
        onPressed: () => roomModel.addOptionFee(),
        child: Text("添加额外收费项"),
      ),
    ));
    return GreatGradientButton(
      onPressed: () {},
      onLongPress: () => roomModel.saveFee(context),
      colors: [Colors.lightBlueAccent, Colors.blue],
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: list),
    );
  }

  Widget feeTextField(
      TextEditingController controller, String labelText, Widget icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      autofocus: false,
      maxLines: 1,
      obscureText: false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        icon: icon,
      ),
    );
  }

  Widget optionFeeTextField(TextEditingController nameTextController,
      TextEditingController feeTextController, VoidCallback onCancel) {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
            child: TextField(
          controller: nameTextController,
          keyboardType: TextInputType.text,
          autofocus: false,
          maxLines: 1,
          obscureText: false,
          style: TextStyle(color: Colors.white),
        )),
        Container(height: 20, child: VerticalDivider(color: Colors.grey)),
        Expanded(
            flex: 3,
            child: TextField(
              controller: feeTextController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              autofocus: false,
              maxLines: 1,
              obscureText: false,
              style: TextStyle(color: Colors.white),
            )),
        IconButton(
            icon: Icon(
              Icons.cancel,
              color: Colors.red,
            ),
            onPressed: onCancel),
      ],
    );
  }

  Widget _dayWidget() {
    var roomModel = Provider.of<RoomModel>(context);
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                color: roomModel.selectLeft ? Colors.lightBlueAccent : null,
                child: InkWell(
                  onTap: () => roomModel.selected(true),
                  child: Text(
                    roomModel.leftTime(),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Text(
                "-",
                style: TextStyle(fontSize: 18),
              ),
              Container(
                color: !roomModel.selectLeft ? Colors.lightBlueAccent : null,
                child: InkWell(
                  onTap: () => roomModel.selected(false),
                  child: Text(
                    roomModel.rightTime(),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: fields(roomModel, true),
                ),
              ),
              Container(height: 20, child: VerticalDivider(color: Colors.grey)),
              Expanded(
                child: Column(
                  children: fields(roomModel, false),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> fields(RoomModel roomModel, bool left) {
    return [
      TextField(
        controller: left
            ? roomModel.leftElectController
            : roomModel.rightElectController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: roomModel.reCalculate,
        autofocus: false,
        maxLines: 1,
        obscureText: false,
        decoration: InputDecoration(
          labelText: "用电量",
          contentPadding: EdgeInsets.all(5.0),
        ),
      ),
      Container(
        height: 5,
      ),
      TextField(
        controller: left
            ? roomModel.leftWaterController
            : roomModel.rightWaterController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: roomModel.reCalculate,
        autofocus: false,
        maxLines: 1,
        obscureText: false,
        decoration: InputDecoration(
          labelText: "用水量",
          contentPadding: EdgeInsets.all(5.0),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () => roomModel.saveDate(context, left),
            child: Text("保存"),
          ),
        ],
      )
    ];
  }




  double _fontSize=15;

  Widget _caclulateResultTestWidget() {
    var roomModel = Provider.of<RoomModel>(context);
    var fr=roomModel.calculateResult();

    List<Widget> list = [];

    if (fr == null) {
      list = [Text("数据不够算不出来")];
    } else {
      list = [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.atm,
                      color: Colors.blueGrey,
                    ),
                    str("电费: "),
                    str("${fr.electFee} 元/度"),
                  ],
            )),
            Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.fiber_manual_record,
                      color: Colors.blueGrey,
                    ),
                    str("水费: "),
                    str("${fr.waterFee} 元/度"),
                  ],
            )),
          ],
        ),
        Container(
          height: 5,
        ),
        Container(
          child: str("${roomModel.room.name}"),
        ),
        Container(
          height: 5,
        ),
        Container(
          child: str("${Util.formatDay(fr.date)}"),
        ),
        Container(
          height: 5,
        ),
        Slider(
          value: _fontSize,
          max: 20,
          min: 5,
          activeColor: Colors.blue,
          onChanged: (double val) {
            _fontSize=val;
            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
            roomModel.notifyListeners();
          },
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FeeItemDataTable(
            rowHeight: 60,
            items: fr.items,
            fontSize: _fontSize,
          ),
        )
      ];

    }

    return Container(
      color: Colors.grey,
      child: Column(
        children: [
          RepaintBoundary(
            key: rootWidgetKey,
            child: Container(
                color: Colors.grey,
                child:Column(
                  children: list,
                )
            ),
          ),
          if(fr!=null)
            ElevatedButton(
              onPressed: () => roomModel.saveFeeSnapshot(context, fr),
              child: Text("保存"),
            ),
        ],
      ),
    );
  }

  DataRow dataRow(String c1,  String c3) {
    return DataRow(cells: [
      DataCell(str(c1)),
      DataCell(str(c3)),
    ]);
  }

  Widget str(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: _fontSize),
    );
  }
}
