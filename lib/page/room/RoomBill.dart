import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/App.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/page/room/Model.dart';
import 'package:hermes/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'FeeItemDataTable.dart';

class RoomBill extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RoomBillState();
  }
}

class RoomBillState extends HermesState<RoomBill> {

  bool _legacy = false;

  GlobalKey _resultKey = GlobalKey();
  double _amountFontSize = 18;
  double _fontSize = 14;
  double _subFontSize = 11;

  @override
  Widget build(BuildContext context) {
    var param = (ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>);
    Printer.printMapJsonLog(param);
    var id = param["roomId"] as int;
    var feeResult = param["feeResult"] as FeeResult;
    return ChangeNotifierProvider(
      create: (BuildContext context) => RoomBillModel(id, feeResult),
      child: Consumer<RoomBillModel>(
        builder: (context, model, child) {
          final result = model.feeResult;

          return Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              // Sticky header
                backgroundColor: AppColors.surface,
              title: _buildHeader(result),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.change_circle),
                    onPressed: () {
                      setState(() {
                        _legacy = !_legacy;
                      });
                    }),

              ],
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RepaintBoundary(
                      key: _resultKey,
                      child: !_legacy?_buildBill(model):_buildBillLegacy(result),
                    ),
                    Slider(
                      value: _fontSize,
                      max: 16,
                      min: 5,
                      activeColor: AppColors.primaryContainer,
                      onChanged: (double val) {
                        setState(() {
                          _amountFontSize = val + 4;
                          _fontSize = val;
                          _subFontSize = val - 3;
                        });
                      },
                    ),
                    _buildSaveButton(model),
                    SizedBox(height: 32,)
                  ],
                ),
              ),
            )
          );
        },
      ),
    );
  }


  Widget _buildBill(RoomBillModel model){
    final result = model.feeResult;
    final room = result.name;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final dateRange = '${dateFormat.format(result.subDate)} — ${dateFormat.format(result.mainDate)}';

    // Separate meter items
    final electricItems = model.electricItems;
    final waterItems = model.waterItems;

    return Container(
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
        child: Column(
          children: [
            // Editorial header
            _buildEditorialHeader(room,dateRange),
            SizedBox(height: 16),

            // Meter readings section
            if (electricItems.isNotEmpty || waterItems.isNotEmpty)
              _buildMeterReadings(electricItems, waterItems),
            SizedBox(height: 16),

            // Fee details section
            _buildFeeDetails(model),
          ],
        ),
      ),
    );
  }

  Widget _text(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: _fontSize),
    );
  }

  Widget _buildBillLegacy(FeeResult result){
    return Container(
        color: Colors.white,
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
                        _text("电费: "),
                        _text("${result.elect} 元/度"),
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
                        _text("水费: "),
                        _text("${result.water} 元/度"),
                      ],
                    )),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: _text("${result.name}"),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: _text("${Util.formatDay(result.mainDate)}"),
            ),
            SizedBox(
              height: 5,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: FeeItemDataTable(
                rowHeight: 60,
                items: result.items,
                fontSize: _fontSize,
              ),
            )
          ],
        ));
  }

  void _captureContent(RoomBillModel model) async {
    if(!(await App.grantStoragePermission())){
      Toast.show("获取文件访问权限失败", duration: 2,gravity: Toast.bottom);
      return;
    }
    // Permission
    RenderRepaintBoundary? boundary = _resultKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    var image = await boundary?.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image?.toByteData(format: ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    model.capturePng(pngBytes!);
  }

  Widget _buildSaveButton(RoomBillModel model){
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async{
                    await model.doSave();
                    Toast.show("保存成功!");
                    _captureContent(model);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.save, size: 12, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          '保存并分享',
                          style: TextStyle(
                            fontSize: _subFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
    );
  }
  
  Widget _buildHeader(FeeResult result) {
    return Text(
      '${result.name} • 收据详情',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildEditorialHeader(String room,String dateRange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 2),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                // '收据详情',
                room,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: AppColors.onSurfaceVariant),
                  SizedBox(width: 6),
                  Text(
                    dateRange,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )

      ],
    );
  }

  Widget _buildMeterReadings(
      List<MeterReadings> electricItems, List<MeterReadings> waterItems) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '抄表读数',
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Electric meters on left, water meters on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Electric meters (left side)
              if (electricItems.isNotEmpty)
                Expanded(
                  child: Column(
                    children: electricItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < electricItems.length - 1 ? 16 : 0),
                        child: _buildMeterItem(item, Icons.bolt, '电表 ${index + 1} (kWh)'),
                      );
                    }).toList(),
                  ),
                ),
              if(electricItems.isNotEmpty&&waterItems.isNotEmpty)
                SizedBox(width: 10,),
              // Water meters (right side)
              if (waterItems.isNotEmpty)
                Expanded(
                  child: Column(
                    children: waterItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < waterItems.length - 1 ? 16 : 0),
                        child: _buildMeterItem(item, Icons.water_drop, '水表 ${index + 1} (m³)'),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeterItem(MeterReadings meterReading, IconData icon, String title) {

    double current = meterReading.current;
    double previous = meterReading.previous;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meter label
        Row(
          children: [
            Icon(icon, size: _fontSize, color: AppColors.secondary),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: _subFontSize,
                letterSpacing: 1.35,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),

        // Current reading
        Container(
          padding: EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.2)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('本次', style: TextStyle(fontSize: _subFontSize, color: AppColors.onSurfaceVariant)),
              Text(
                current.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2),

        // Previous reading (dimmed)
        Opacity(
          opacity: 0.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('上次', style: TextStyle(fontSize: _subFontSize, color: AppColors.onSurfaceVariant)),
              Text(
                previous.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeeDetails(RoomBillModel model) {
    final feeResult = model.feeResult;
    final name = feeResult.name;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final mainDate = dateFormat.format(feeResult.mainDate);
    final items = model.items;
    final totalAmount = feeResult.totalAmount;

    List<Widget> feeWidgets = [];
    // Add fee items
    for (var item in items) {
      feeWidgets.add(_buildFeeRow(item.name, item.desc, item.fee));
      feeWidgets.add(SizedBox(height: 12));
    }

    // Remove last spacing
    if (feeWidgets.isNotEmpty) {
      feeWidgets.removeLast();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '费用明细',
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.bolt, size: _fontSize, color: AppColors.secondary),
                  SizedBox(width: 2),
                  Text(
                    "电费: ${model.feeResult.elect} 元/度",
                    style: TextStyle(
                      fontSize: _subFontSize,
                      letterSpacing: 1.35,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.water_drop, size: _fontSize, color: AppColors.secondary),
                  SizedBox(width: 2),
                  Text(
                    "水费: ${model.feeResult.water} 元/度",
                    style: TextStyle(
                      fontSize: _subFontSize,
                      letterSpacing: 1.35,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            ],
          ),

          SizedBox(height: 16),
          ...feeWidgets,
          SizedBox(height: 20),

          // Total section
          Container(
            padding: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '应付总额',
                      style: TextStyle(
                        fontSize: _subFontSize,
                        letterSpacing: 0.9,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          totalAmount.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -1,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String title, String? subtitle, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: _subFontSize,
                    fontStyle: subtitle.contains('*') ? FontStyle.italic : FontStyle.normal,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '¥',
              style: TextStyle(
                fontSize: _subFontSize,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(width: 4),
            Text(
              amount.toStringAsFixed(2),
              style: TextStyle(
                fontSize: _amountFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
