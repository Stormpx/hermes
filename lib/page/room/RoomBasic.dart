import 'package:flutter/material.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/component/InitializingPage.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/model/Data.dart';
import 'package:hermes/page/room/RoomFeeForm.dart';
import 'package:hermes/page/room/RoomReading.dart';
import 'package:hermes/page/room/RoomSanpshotsList.dart';
import 'package:hermes/page/room/RoomSnapshotChart.dart';
import 'package:hermes/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'Model.dart';

class RoomBasic extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RoomBasicState();
  }
}

class RoomBasicState extends HermesState<RoomBasic> {
  void _enterFeeForm(RoomModel model) async {
    RoomWithOptFee room = model.room!;
    bool? submit = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => ChangeNotifierProvider(
            create: (ctx) => RoomFeeFormModel(room.room.copyWith(), room.optFee.toList()),
            child: RoomFeeForm(),
          ),
        ));
    if (submit ?? false) {
      model.reload();
    }
  }

  void _enterSnapshotPage(RoomModel model) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => ChangeNotifierProvider(
            create: (create) => RoomSnapshotModel(model.id,model.title??""),
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                  appBar: AppBar(
                    title: Text("${model.title ?? ""} 记录"),
                    bottom: TabBar(tabs: [
                      Tab(
                        text: "列表",
                      ),
                      Tab(
                        text: "折线图",
                      ),
                    ]),
                  ),
                body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                  RoomSnapshotList(),
                  RoomSnapshotChart()
                ]),
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var param =
    (ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>);
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
              title: Text(name ?? "加载中"),
              initialized: value != null,
              loadingText: Text("获取数据中..."),
              builder: () {
                return ChangeNotifierProvider.value(
                  value: value!,
                  child: Consumer<RoomModel>(
                    builder: (ctx, model, child) {
                      return Scaffold(
                          backgroundColor: AppColors.surface,
                          appBar: AppBar(
                            backgroundColor: AppColors.surface.withOpacity(0.8),
                            elevation: 0,
                            title: Text(
                              "套间设置",
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            actions: [
                              // IconButton(
                              //   icon: Icon(Icons.receipt_long),
                              //   onPressed: () {
                              //     var id = model.id;
                              //     var fee = model.calculateResult();
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (c) => RoomBill(),
                              //         settings: RouteSettings(arguments: {"roomId": id, "feeResult": fee}),
                              //       ),
                              //     );
                              //   },
                              // ),
                            ],
                          ),
                          body: GestureDetector(
                            onTap: () => FocusScope.of(context).unfocus(),
                            child: Stack(
                              children: [
                                SingleChildScrollView(
                                  padding: EdgeInsets.only(bottom: 200),
                                  child: Column(
                                    children: [
                                      _buildHeader(model),
                                      SizedBox(height: 24),
                                      _buildRentCard(model),
                                      SizedBox(height: 16),
                                      _buildFeeGrid(model),
                                      SizedBox(height: 16),
                                      _buildMeterSettings(model),

                                    ],
                                  ),
                                ),
                                _buildActionButtons(model),
                              ],
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

  Widget _buildHeader(RoomModel model) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "配置信息",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.outlineVariant.withOpacity(0.2),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            model.title ?? "套间",
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "基础信息",
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "最后更新: ${model.room?.room.leastMarkDate != null ? Util.formatDay(model.room!.room.leastMarkDate!) : '未更新'}",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentCard(RoomModel model) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "每月基础租金",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.2,
                  ),
                ),
                Icon(
                  Icons.payments,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "¥",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  "${(model.room?.room.rent ?? 0).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeGrid(RoomModel model) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildFeeCard(
              icon: Icons.bolt,
              title: "电费",
              value: "${(model.room?.room.electFee ?? 0).toStringAsFixed(2)}",
              unit: "kWh",
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildFeeCard(
              icon: Icons.water_drop,
              title: "水费",
              value: "${(model.room?.room.waterFee ?? 0).toStringAsFixed(2)}",
              unit: "m³",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.secondary,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            unit,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeterSettings(RoomModel model) {
    var room = model.room;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "抄表设置",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "电费",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${(room?.room.electMeters ?? 1).toString().padLeft(2, '0')} ",
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            TextSpan(
                              text: "个表",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "水费",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${(room?.room.waterMeters ?? 1).toString().padLeft(2, '0')} ",
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            TextSpan(
                              text: "个表",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (room?.optFee.isNotEmpty ?? false) ...[
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.outlineVariant.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "额外收费项",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...room!.optFee.map((opt) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                opt.name,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                "¥${(opt.fee ?? 0).toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(RoomModel model) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surface.withOpacity(0),
              AppColors.surface,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => RoomReading(),
                      settings: RouteSettings(arguments: model),
                    ),
                  );
                },
                icon: Icon(Icons.receipt, size: 18),
                label: Text(
                  "生成收据",
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 12,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _enterFeeForm(model),
                      icon: Icon(Icons.edit, size: 18),
                      label: Text(
                        "编辑设置",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerHighest.withOpacity(0.8),
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.outlineVariant.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _enterSnapshotPage(model),
                      icon: Icon(Icons.history, size: 18),
                      label: Text(
                        "查看历史",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerHighest.withOpacity(0.8),
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.outlineVariant.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}