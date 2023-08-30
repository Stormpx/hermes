import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/component/ZoomableChart.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/model/Data.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/page/room/FeeItemDataTable.dart';
import 'package:hermes/page/room/Model.dart';
import 'package:provider/provider.dart';

class RoomSnapshotChart extends StatefulWidget {
  @override
  _RoomSnapshotChartState createState() => _RoomSnapshotChartState();
}

class _LineType {
  bool enabled = true;
  Color color;

  _LineType(this.enabled, this.color);
}

class _Range {
  bool selected = false;
  String name;

  _Range(this.selected, this.name);
}

class _RoomSnapshotChartState extends HermesState<RoomSnapshotChart>
    with TickerProviderStateMixin {
  final _LineType _total = _LineType(true, Colors.green);
  final _LineType _elect = _LineType(true, Colors.yellow.shade700);
  final _LineType _water = _LineType(true, Colors.lightBlue.shade400);

  final _Range _all = _Range(false, "全部");
  final _Range _1year = _Range(false, "近1年");
  final _Range _6Month = _Range(false, "近6月");
  final _Range _thisYear = _Range(true, "今年");

  double? selected_x;

  DateTime minX = DateTime.utc(DateTime.now().year - 1, 12, 31);
  DateTime maxX = DateTime.now();

  void _selectRange(RoomSnapshotModel model, _Range range) {
    _all.selected = false;
    _1year.selected = false;
    _6Month.selected = false;
    _thisYear.selected = false;

    if (_all == range) {
      minX = model.minimumTime;
      maxX = model.maximumTime;
    } else if (_1year == range) {
      minX = DateTime.now().subtract(Duration(days: 365));
      maxX = DateTime.now();
    } else if (_6Month == range) {
      minX = DateTime.now().subtract(Duration(days: 182));
      maxX = DateTime.now();
    } else if (_thisYear == range) {
      minX = DateTime.utc(DateTime.now().year - 1, 12, 31);
      maxX = DateTime.now();
    }
    maxX = model.maximumTime;
    range.selected = true;
  }

  String _xToDateTime(double x) {
    var day = DateTime.fromMillisecondsSinceEpoch(x.toInt());

    return Util.formatDay(day);
  }

  List<LineTooltipItem> defaultLineTooltipItem(
      double baselineY, List<LineBarSpot> touchedSpots) {
    return touchedSpots.indexed.map((e) {
      var index = e.$1;
      var touchedSpot = e.$2;
      var spotsColor = touchedSpot.bar.color ?? Colors.blueGrey;
      final textStyle = TextStyle(
        color: spotsColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );
      return LineTooltipItem("", textStyle, children: [
        if (index == 0)
          TextSpan(
            text: "${_xToDateTime(touchedSpot.x)}\n",
          ),
        TextSpan(
            text:
                "${(spotsColor == _elect.color || spotsColor == _water.color) ? touchedSpot.y - baselineY : touchedSpot.y}",
            style: textStyle)
      ]);
    }).toList();
  }

  List<RoomSnapshotRecord> getRangeOfRecords(
      double min, double max, List<RoomSnapshotRecord> records) {
    var minDate = DateTime.fromMillisecondsSinceEpoch(min.toInt());
    var maxDate = DateTime.fromMillisecondsSinceEpoch(max.toInt());
    return records
        .where((element) =>
            minDate.compareTo(element.snapshot.snapshotStartDate) <= 0)
        .where((element) =>
            maxDate.compareTo(element.snapshot.snapshotStartDate) >= 0)
        .toList();
  }

  double _xWithOffset(double x, int offset) => x ;

  List<FlSpot> _buildTotalSpot(
      double min, double max, RoomSnapshotModel model) {
    var records = getRangeOfRecords(min, max, model.records);
    int offset = 0;
    List<FlSpot> result = [];
    for (final iter in records.indexed) {
      var r = iter.$2;
      if (iter.$1 != 0) {
        if (model.records[iter.$1 - 1].snapshot.snapshotStartDate ==
            r.snapshot.snapshotStartDate) {
          offset++;
        } else {
          offset = 0;
        }
      }
      result.add(FlSpot(
          _xWithOffset(
              r.snapshot.snapshotStartDate.millisecondsSinceEpoch.toDouble(),
              offset),
          (r.snapshot.totalAmount ?? 0).roundToDouble()));
    }
    return result;
  }

  List<FlSpot> _buildElectSpot(
      double min, double max, RoomSnapshotModel model) {
    var records = getRangeOfRecords(min, max, model.records);
    int offset = 0;
    List<FlSpot> result = [];
    for (final iter in records.indexed) {
      var r = iter.$2;
      if (iter.$1 != 0) {
        if (model.records[iter.$1 - 1].snapshot.snapshotStartDate ==
            r.snapshot.snapshotStartDate) {
          offset++;
        } else {
          offset = 0;
        }
      }
      result.add(FlSpot(
          _xWithOffset(
              r.snapshot.snapshotStartDate.millisecondsSinceEpoch.toDouble(),
              offset),
          (r.snapshot.elect ?? 0) + model.minimumTotal));
    }
    return result;
  }

  List<FlSpot> _buildWaterSpot(
      double min, double max, RoomSnapshotModel model) {
    var records = getRangeOfRecords(min, max, model.records);
    int offset = 0;
    List<FlSpot> result = [];
    for (final iter in records.indexed) {
      var r = iter.$2;
      if (iter.$1 != 0) {
        if (model.records[iter.$1 - 1].snapshot.snapshotStartDate ==
            r.snapshot.snapshotStartDate) {
          offset++;
        } else {
          offset = 0;
        }
      }
      result.add(FlSpot(
          _xWithOffset(
              r.snapshot.snapshotStartDate.millisecondsSinceEpoch.toDouble(),
              offset),
          (r.snapshot.water ?? 0) + model.minimumTotal));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomSnapshotModel>(
      builder: (ctx, model, child) {
        var ts = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
        if (selected_x == null) {}
        return SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Text(
                        "总收费",
                        style: ts,
                      ),
                      Switch(
                          value: _total.enabled,
                          activeColor: _total.color,
                          onChanged: (b) => setState(() => _total.enabled = b)),
                    ],
                  ),
                  Row(
                    children: [
                      Text("用电量", style: ts),
                      Switch(
                          value: _elect.enabled,
                          activeColor: _elect.color,
                          onChanged: (b) => setState(() => _elect.enabled = b)),
                    ],
                  ),
                  Row(
                    children: [
                      Text("用水量", style: ts),
                      Switch(
                          value: _water.enabled,
                          activeColor: _water.color,
                          onChanged: (b) => setState(() => _water.enabled = b))
                    ],
                  ),
                ],
              ),
              SizedBox(
                  height: 400,
                  child: LineChart(LineChartData(
                    maxX: maxX.millisecondsSinceEpoch.toDouble() * 1.0001,
                    minX: minX.millisecondsSinceEpoch.toDouble() * 0.9999,
                    gridData: FlGridData(show: false),
                    clipData: FlClipData.all(),
                    extraLinesData: ExtraLinesData(verticalLines: [
                      if (selected_x != null) VerticalLine(x: selected_x!,color: Colors.red.withOpacity(0.5))
                    ]),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                            reservedSize: 30,
                            showTitles: true,
                            getTitlesWidget: (x, meta) => Text("")),
                      ),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (x, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  angle: 320,
                                  space: 10,
                                  child: Text(
                                      "${(x == meta.max || x == meta.min) ? "" : Util.formatDay(DateTime.fromMillisecondsSinceEpoch(x.toInt()))}"),
                                );
                              })),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 44,
                              // interval: 50,
                              getTitlesWidget: (y, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text("${y.toStringAsFixed(0)}"),
                                );
                              })),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 44,
                              // interval: 50,
                              getTitlesWidget: (y, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                      "${(y - model.minimumTotal).toStringAsFixed(0)}"),
                                );
                              })),
                    ),
                    lineTouchData: LineTouchData(
                        enabled: true,
                        touchCallback: (event, response) {
                          if (event is FlTapUpEvent) {
                            var tapupEvent = event;
                            if (response != null) {
                              setState(() {
                                selected_x = response.lineBarSpots?[0].x;
                              });
                            }
                          }
                        },
                        touchTooltipData: LineTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          showOnTopOfTheChartBoxArea: true,
                          getTooltipItems: (items) => this
                              .defaultLineTooltipItem(
                                  model.minimumTotal, items),
                        )),
                    lineBarsData: [
                      if (_total.enabled)
                        LineChartBarData(
                          color: _total.color,
                          spots: _buildTotalSpot(
                              minX.millisecondsSinceEpoch.toDouble(),
                              maxX.millisecondsSinceEpoch.toDouble(),
                              model),
                          isCurved: false,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                          ),
                        ),
                      if (_elect.enabled)
                        LineChartBarData(
                          color: _elect.color,
                          spots: _buildElectSpot(
                              minX.millisecondsSinceEpoch.toDouble(),
                              maxX.millisecondsSinceEpoch.toDouble(),
                              model),
                          isCurved: false,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                          ),
                        ),
                      if (_water.enabled)
                        LineChartBarData(
                          color: _water.color,
                          spots: _buildWaterSpot(
                              minX.millisecondsSinceEpoch.toDouble(),
                              maxX.millisecondsSinceEpoch.toDouble(),
                              model),
                          isCurved: false,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                          ),
                        ),
                    ],
                    borderData: FlBorderData(
                      show: false,
                    ),
                  ))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _RangeRadio(model, _all),
                  _RangeRadio(model, _1year),
                  _RangeRadio(model, _6Month),
                  _RangeRadio(model, _thisYear),
                ],
              ),
              Divider(
                height: 10,
                color: Colors.black,
              ),
              _snapshotBlock(model),
              SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
    );
  }

  Widget _RangeRadio(RoomSnapshotModel model, _Range range) {
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
              range.selected ? Colors.lightBlue.withOpacity(0.3) : null),
        ),
        child: Container(
          child: Text(
            range.name,
            style: TextStyle(
                color:
                    range.selected ? Colors.lightBlue : Colors.grey.shade600),
          ),
        ),
        onPressed: () => setState(() => _selectRange(model, range)),
      ),
    );
  }

  Widget _snapshotBlock(RoomSnapshotModel model) {
    if (selected_x == null) {
      return Container();
    }
    var key = DateTime.fromMillisecondsSinceEpoch(selected_x!.toInt());
    var result = model.records
        .where(
            (element) => element.snapshot.snapshotStartDate.compareTo(key) == 0)
        .toList();
    return CarouselSlider.builder(
      options: CarouselOptions(
          height: 500.0,
          viewportFraction: 1.0,
          enableInfiniteScroll: false,
          disableCenter: true),
      itemCount: result.length,
      itemBuilder: (BuildContext context, int index, int realIndex) {
        var record = result[index];
        return SingleChildScrollView(
          child: Container(
            color: Colors.grey,
            child: Container(
                padding: EdgeInsets.only(top: 5),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text("${index+1}/${result.length}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(record.endDate),
                        Text(" - "),
                        Text(record.startDate),
                      ],
                    ),
                    FeeItemDataTable(
                      rowHeight: 63,
                      items: record.items
                          .map((e) => FeeItem.fromSnapshotItem(e))
                          .toList(),
                      fontSize: 14,
                    )
                  ],
                )),
          ),
        );
      },
    );
  }
}
