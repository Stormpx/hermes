
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hermes/kit/ExprValidator.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/page/room/Model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class RoomDayMarker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RoomDayMarkerState();
  }
}

class RoomDayMarkerState extends State<RoomDayMarker> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _electFieldKey = GlobalKey<FormBuilderFieldState>();
  final _waterFieldKey = GlobalKey<FormBuilderFieldState>();


  bool _edit = false;
  final ExpansionTileController expansionController=ExpansionTileController();
  bool _expanded = false;

  Map<int,RoomMeter> _tmpMeters={};


  DateTime? dayTapTime;

  void _saveTemp(MarkerBlock block) {
    var meters = block.meters;
    Map<int,RoomMeter> tmpMeters={};
    for(int i=1;i<=meters;i++){
      var meterGroup = block.roomMeters[i];
      tmpMeters[i] = RoomMeter(meterGroup?.elect??0, meterGroup?.water??0);
    }
    _tmpMeters = tmpMeters;
  }

  void _pressCancel(MarkerBlock block) {
    setState(() {
      var meters = block.meters;
      for (int i = 1; i <= meters; i++) {
        var meter = _tmpMeters[i];
        block.setValueBySeq(i, meter?.elect??0, meter?.water??0);
      }
      _edit = false;
    });
  }

  void _pressSave(MarkerBlock block) async {
    var validate = _formKey.currentState?.saveAndValidate();
    debugPrint(_formKey.currentState?.value.toString());
    if (!(validate ?? false)) {
      return;
    }
    var val = _formKey.currentState?.value;
    if (val == null) {
      return;
    }
    await block.submit();
    _edit = false;
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarkerBlock>(builder: (ctx, block, child) {
      _saveTemp(block);
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExpansionTile(
            controller: expansionController,
            title: Text(
              Util.formatDay(block.selectedDay),
              style: TextStyle(
                letterSpacing: 5.0,
                fontSize: 19,
                color: Colors.grey.shade700,
              ),
            ),
            trailing: Wrap(
              children: [
                Text(
                  _expanded ? "收起日历" : "展开日历",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(_expanded
                    ? Icons.expand_less_outlined
                    : Icons.expand_more_outlined)
              ],
            ),
            children: [
              TableCalendar(
                locale: 'zh_CN',
                firstDay: DateTime.utc(1976, 9, 9),
                lastDay: block.lastDay ?? DateTime.utc(2050, 3, 14),
                focusedDay: block.focusedDay,
                selectedDayPredicate: (day) {
                  return Util.isSameDay(block.selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) async {
                  Printer.info("$selectedDay $focusedDay");
                  block.focusedDay=focusedDay;
                  await block.loadDay(selectedDay);
                  _saveTemp(block);
                  FocusScope.of(context).unfocus();
                  var now = DateTime.now();
                  if(dayTapTime==null||now.difference(dayTapTime!)>=Duration(milliseconds: 200)){
                    dayTapTime=now;
                  }else{
                    dayTapTime=null;
                    expansionController.collapse();
                  }
                },
                availableCalendarFormats: {
                  CalendarFormat.month: 'Month',
                },
                onPageChanged: (date) {
                  block.loadEvents(date);
                },
                eventLoader: (day) {
                  bool marked = block.roomModel?.isDayMarked(day)??false;
                  return marked?[1]:[];
                },
                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, date, _) {
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.amber[400],
                      width: 100,
                      height: 100,
                      child: Text(
                        '${date.day}',
                        style: TextStyle().copyWith(fontSize: 16.0),
                      ),
                    );
                  },
                ),
              )
            ],
            onExpansionChanged: (bool) {
              setState(() {
                _expanded = bool;
              });
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (!_edit) _enabledEditButton(block),
              if (_edit) _editingButtonGroup(block),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "用电量",
                    style: TextStyle(
                      letterSpacing: 5.0,
                      fontSize: 17,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    "用水量",
                    style: TextStyle(
                      letterSpacing: 5.0,
                      fontSize: 17,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              _editingForm(block)
            ],
          ),
        ],
      );
    });
  }

  Widget _enabledEditButton(MarkerBlock block) {
    return ButtonTheme(
        // height: 50,
        child: TextButton.icon(
      onPressed: () {
        setState(() {
          _saveTemp(block);
          _edit = true;
        });
      },
      label: Text(
        "修改读数",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      icon: Icon(Icons.edit),
      style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.67))),
          side: WidgetStateProperty.all(BorderSide(
            color: Colors.grey.shade300,
          )),
          backgroundColor: WidgetStateProperty.all(Colors.grey.shade300)),
    ));
  }



  Widget _editingButtonGroup(MarkerBlock block) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ButtonTheme(
            // height: 50,
            child: TextButton.icon(
          onPressed: () {
            _pressCancel(block);
          },
          label: Text(
            "取消",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          icon: Icon(Icons.cancel, color: Colors.white),
          style: ButtonStyle(
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.67))),
              backgroundColor: WidgetStateProperty.all(Colors.red)),
        )),
        ButtonTheme(
            // height: 50,
            child: TextButton.icon(
          onPressed: () {
            _pressSave(block);
          },
          label: Text(
            "保存",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          icon: Icon(
            Icons.save,
            color: Colors.white,
          ),
          style: ButtonStyle(
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.67))),
              backgroundColor: WidgetStateProperty.all(Colors.green)),
        )),
      ],
    );
  }

  Widget _editingForm(MarkerBlock block) {
    var meters = block.meters;
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          for (int i = 1; i <= meters; i++)
            _editingRow(block,i,block.meterController(i)),
        ],
      )
    );
  }

  Widget _editingRow(MarkerBlock block,int seq,RoomMeterController meter){

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          Expanded(
            child:  seq>block.electMeters?
            Container()
                :
            FormBuilderTextField(
              name: 'elect-$seq',
              controller: meter.electController,
              autofocus: _edit,
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\.0-9\-+]'))
              ],
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                ExprValidator(errorText: "必须是有效的表达式").validate,
              ]),
              style: TextStyle(color: Colors.black),
              enabled: _edit,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                border: UnderlineInputBorder(borderSide: BorderSide()),
                disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
              ),
              onTap: () {
                if (meter.elect == 0) {
                  meter.electController.text = "";
                }
              },
            ),
          ),
          Container(height: 20, child: VerticalDivider(color: Colors.grey)),
          Expanded(
            child: seq>block.waterMeters?
            Container()
                :
            FormBuilderTextField(
              name: 'water-$seq',
              controller: meter.waterController,
              autofocus: false,
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\.0-9\-+]'))
              ],
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                ExprValidator(errorText: "必须是有效的表达式").validate,
              ]),
              style: TextStyle(color: Colors.black),
              enabled: _edit,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                border: UnderlineInputBorder(borderSide: BorderSide()),
                disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
              ),
              onTap: () {
                if (meter.water == 0) {
                  meter.waterController.text = "";
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
