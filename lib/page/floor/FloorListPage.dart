import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hermes/component/FloatButton.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/model/Data.dart';
import 'package:hermes/page/room/RoomBasic.dart';
import 'package:hermes/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'FloorModel.dart';
import 'FloorDialog.dart';
import 'RoomDialog.dart';

class FloorListPage extends StatefulWidget {
  @override
  _FloorListPageState createState() => _FloorListPageState();
}

class _FloorListPageState extends HermesState<FloorListPage> {
  final FocusNode blankNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _slidableGroup = GlobalKey();

  TextEditingController floorNameController = TextEditingController();
  TextEditingController floorSortController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildHeaderSection(String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hermes',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.33,
              letterSpacing: 0.1,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 36,
              height: 1.11,
              letterSpacing: -0.025,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '管理楼层分布与具体单元。拖动左侧图标可调整楼层顺序。',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorItem(FloorModel model, FloorWithRooms floorWithRooms, int index, bool isExpanded) {
    return Container(
      key: ObjectKey(floorWithRooms.floor.name),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isExpanded ? Color(0xFFFFFFFF) : Color(0xFFF3F4F1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: Color(0x0D000000),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
                BoxShadow(
                  color: Color(0x33C1C8C2),
                  offset: Offset(0, 0),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ]
            : null,
        border: isExpanded
            ? Border.all(
                color: Color(0x1AC1C8C2),
                width: 1,
              )
            : Border.all(
                color: Colors.transparent,
                width: 1,
              ),
      ),
      child: Column(
        children: [
          // Floor header
          Slidable(
            // key: ObjectKey(floorWithRooms.floor.name),
            groupTag: _slidableGroup,
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  label: '编辑',
                  backgroundColor: Colors.green,
                  icon: Icons.edit,
                  onPressed: (BuildContext ctx) async {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return FloorDialog(
                          initValue: {"name": floorWithRooms.floor.name},
                          onSubmit: (data) async {
                            var name = data["name"] as String;
                            if (await model.updateFloor(
                                floorWithRooms.floor.id!, name)) {
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
                SlidableAction(
                  label: '删除',
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  onPressed: (BuildContext context) async {
                    var confirm = await showDeleteConfirmDialog([
                      Text("您确定要删除楼层 ${floorWithRooms.floor.name} 吗?"),
                      Text("删除也会将套间一并删除"),
                    ]);
                    if (confirm ?? false) {
                      model.deleteFloor(floorWithRooms);
                    }
                  },
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: isExpanded ? Color(0x66F3F4F1) : Colors.transparent,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8),
                  bottom: isExpanded ? Radius.zero : Radius.circular(8),
                ),
                border: isExpanded
                    ? Border(
                        bottom: BorderSide(
                          color: Color(0x1AC1C8C2),
                          width: 1,
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  // Drag handle
                  ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.menu,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Add room button
                  Container(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        size: 25,
                        color: AppColors.secondary,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return RoomDialog(
                              title: "新增套间",
                              floorName: floorWithRooms.floor.name,
                              onSubmit: (data) async {
                                if (await model.addRoom(
                                    floorWithRooms.floor.id!,
                                    data["name"] as String)) {
                                  Navigator.of(context).pop();
                                }
                              },
                            );
                          },
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ),
                  SizedBox(width: 24),
                  // Floor name (clickable to expand/collapse)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        model.selectFloor(isExpanded ? null : floorWithRooms.floor);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        floorWithRooms.floor.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          height: 1.4,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  // Room count badge (clickable to expand/collapse)
                  GestureDetector(
                    onTap: () {
                      model.selectFloor(isExpanded ? null : floorWithRooms.floor);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: floorWithRooms.rooms.length>0 ? AppColors.greenLight : Color(0x80E2E3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${floorWithRooms.rooms.length} 单元',
                        style: TextStyle(
                          fontWeight: isExpanded ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 14,
                          height: 1.33,
                          color: isExpanded ? AppColors.greenDark : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Expand/collapse button
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {
                      model.selectFloor(isExpanded ? null : floorWithRooms.floor);
                    },
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          // Room list (expanded)
          if (isExpanded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: floorWithRooms.rooms.map((room) {
                  return _buildRoomItem(model, floorWithRooms, room);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomItem(FloorModel model, FloorWithRooms floorWithRooms, Room room) {
    return GestureDetector(
      onTap: () {
        _enterRoom(model, room);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: 12),
            // Room info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_money, size: 14, color: AppColors.secondary),
                          Text(
                            '${room.rent ?? 0}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 15,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flash_on, size: 14, color: AppColors.secondary),
                          Text(
                            '${room.electFee ?? 0}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 15,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.water_drop, size: 14, color: AppColors.secondary),
                          Text(
                            '${room.waterFee ?? 0}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Edit button
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 25,
                color: AppColors.secondary,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => RoomDialog(
                    title: "编辑套间名称",
                    floorName: floorWithRooms.floor.name,
                    initValue: {"name": room.name},
                    onSubmit: (data) async {
                      if (await model.updateRoom(room.id!, data["name"] as String)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                );
              },
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 4),
            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 25,
                color: AppColors.secondary,
              ),
              onPressed: () async {
                var confirm = await showDeleteConfirmDialog([
                  Text("您确定要删除套间 ${room.name} 吗?"),
                ]);
                if (confirm ?? false) {
                  model.delRoom(floorWithRooms, room);
                }
              },
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorList(FloorModel model) {
    var list = model.list;
    return SlidableAutoCloseBehavior(
      child: ReorderableListView.builder(
        scrollDirection: Axis.vertical,
        scrollController: _scrollController,
        padding: EdgeInsets.only(bottom: 75),
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          var floorWithRooms = list[index];
          var isExpanded = model.selectedFloorId == floorWithRooms.floor.id;
          return _buildFloorItem(model, floorWithRooms, index, isExpanded);
        },
        itemCount: list.length,
        onReorder: (oldIndex, newIndex) {
          Printer.printMapJsonLog("$oldIndex------$newIndex");
          model.floorReorder(oldIndex, newIndex);
        },
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  void _enterRoom(FloorModel model, Room room) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => RoomBasic(),
        settings: RouteSettings(arguments: {"roomId": room.id, "name": room.name}),
      ),
    );
    model.reloadRoomInFloor(room.floorId, room.id!);
  }

  @override
  Widget build(BuildContext context) {
    var param = (ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>);
    Printer.printMapJsonLog(param);
    var id = param["buildingId"] as int;
    var name = param["name"] as String?;
    return ChangeNotifierProvider(
      create: (c) => FloorModel(id),
      child: Consumer<FloorModel>(
        builder: (ctx, model, child) {
          return FloatingDraggableWidget(
            mainScreenWidget: Scaffold(
              backgroundColor: AppColors.surface,
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text("楼层列表"),
                backgroundColor: AppColors.surface,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              ),
              body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(blankNode);
                },
                child: Column(
                  children: [
                    _buildHeaderSection(name??"楼层"),
                    Expanded(
                      child: _buildFloorList(model),
                    ),
                  ],
                ),
              ),
            ),
            floatingWidget: FloatButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return FloorDialog(onSubmit: (data) async {
                      var name = data["name"] as String;
                      if (await model.addFloor(name)) {
                        Navigator.of(context).pop();
                      }
                    });
                  },
                );
              },
            ),
            floatingWidgetWidth: 60,
            floatingWidgetHeight: 60,
            speed: 80,
          );
        },
      ),
    );
  }
}