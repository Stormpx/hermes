import 'dart:async';

import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hermes/App.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/component/FloatButton.dart';
import 'package:hermes/component/InitializingPage.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/page/option/ExtOptionDrawer.dart';
import 'package:hermes/page/building/BuildingListModel.dart';
import 'package:hermes/page/floor/FloorListPage.dart';
import 'package:hermes/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class BuildingListPage extends StatefulWidget {
  @override
  _BuildingListState createState() => _BuildingListState();
}

class _BuildingListState extends HermesState<BuildingListPage> {
  final FocusNode blankNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _slidableGroup = GlobalKey();
  OverlayEntry? overlayEntry;
  bool start = false;

  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (BuildContext context) => BuildingListModel().init(),
      initialData: null,
      catchError: (ctx, e) {
        Printer.error(e);
        Toast.show("获取数据时发生错误");
        App.exitApp();
        return null;
      },
      child: Consumer<BuildingListModel?>(
        builder: (ctx, model, child) {
          return InitializingPage(
            initialized: model != null,
            title: Text("建筑列表"),
            builder: () {
              return ChangeNotifierProvider.value(
                  value: model!,
                  child: Consumer<BuildingListModel?>(
                      builder: (ctx, model, child) {
                        return FloatingDraggableWidget(
                          mainScreenWidget: Scaffold(
                          backgroundColor: AppColors.surface,
                          resizeToAvoidBottomInset: false,
                          appBar: AppBar(
                            backgroundColor: AppColors.surface,
                              title: Text("建筑列表"),
                            ),
                            drawer: ExtOptionDrawer(),
                            drawerEdgeDragWidth: MediaQuery.of(context).size.width/2,
                            onDrawerChanged: (open) {
                              if (!open) {
                                model.reload();
                              }
                            },
                            body: GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).requestFocus(blankNode);
                                },
                                child: buildingList(model!)),
                          ),
                          floatingWidget: FloatButton(
                            onPressed: () {
                              _addNewBuilding(model);
                            },
                          ),
                          floatingWidgetWidth: 60,
                          floatingWidgetHeight: 60,
                          speed: 80,
                        );
                  }));
            },
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final runes = name.runes.toList();
    if (runes.length <= 2) return name;
    return String.fromCharCodes(runes, 0, 2);
  }

  Color _getAvatarColor(int index) => AppColors.avatarColors[index % AppColors.avatarColors.length];
  Color _getAvatarTextColor(int index) => AppColors.avatarTextColors[index % AppColors.avatarTextColors.length];

  Widget buildingList(BuildingListModel model) {
    var list = model.buildings;
    if (!start) {
      start = true;
      if (list.length == 1) {
        Timer(Duration(milliseconds: 300), () {
          _enterBuilding(context, model,list[0]);
        });
      }
    }
    return SlidableAutoCloseBehavior(
        child: ReorderableListView.builder(
          scrollDirection: Axis.vertical,
          scrollController: _scrollController,
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemBuilder: (context, index) {
            var building = list[index];
            var key = ObjectKey(building);
            return Slidable(
              key: key,
              groupTag: _slidableGroup,
              endActionPane: ActionPane(
                motion: ScrollMotion(),
                children: [
                  SlidableAction(
                      label: '编辑',
                      backgroundColor: Colors.green,
                      icon: Icons.edit,
                      onPressed: (BuildContext ctx) async {
                        _updateBuilding(model, building);
                      }),
                  SlidableAction(
                      label: '删除',
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                      onPressed: (BuildContext context) async {
                        var confirm = await showDeleteConfirmDialog([
                          Text("您确定要删除建筑 ${building.name} 吗?"),
                          Text("删除也会将套间一并删除")
                        ]);
                        if (confirm ?? false) {
                          model.delBuilding(building);
                        }
                      })
                ],
              ),
              child: _BuildingCard(
                building: building,
                index: index,
                floorCount: model.getFloorCount(building.id),
                roomCount: model.getRoomCount(building.id),
                onTap: () => _enterBuilding(context, model,building),
                onDrag: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle, color: AppColors.outlineVariant)),
                avatarColor: _getAvatarColor(index),
                avatarTextColor: _getAvatarTextColor(index),
                initials: _getInitials(building.name),
              ),
            );
          },
          itemCount: list.length,
          onReorder: (oldIndex, newIndex) {
            model.buildingReorder(oldIndex, newIndex);
          },
          physics: ClampingScrollPhysics(),
        )
    );
  }

  void _enterBuilding(BuildContext context, BuildingListModel model,Building building) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (c) => FloorListPage(),
          settings: RouteSettings(
              arguments: {"buildingId": building.id, "name": building.name})),
    );
    await model.reload();
  }

  void _addNewBuilding(BuildingListModel model) async {
    Map<String, dynamic>? r = await Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => AddBuildingForm()),
    );

    if (r != null) {
      model.saveNewBuilding(Building(name: r["name"] as String));
    }
  }

  void _updateBuilding(BuildingListModel model, Building building) async {
    Map<String, dynamic> data = {"name": building.name};
    Map<String, dynamic>? r = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (c) => Provider.value(
                value: data,
                child: AddBuildingForm(),
              )),
    );

    Printer.info(r);
    if (r != null) {
      model.updateBuilding(r["name"] as String, building);
    }
  }
}

class _BuildingCard extends StatelessWidget {
  final Building building;
  final int index;
  final int floorCount;
  final int roomCount;
  final VoidCallback onTap;
  final Widget onDrag;
  final Color avatarColor;
  final Color avatarTextColor;
  final String initials;

  const _BuildingCard({
    required this.building,
    required this.index,
    required this.floorCount,
    required this.roomCount,
    required this.onTap,
    required this.onDrag,
    required this.avatarColor,
    required this.avatarTextColor,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                Expanded(child: _buildInfo()),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: AppColors.outlineVariant, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: avatarColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: avatarTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Manrope',
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                building.name,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildBadge(),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildStatItem(Icons.layers_outlined, '$floorCount 楼层'),
            const SizedBox(width: 16),
            _buildStatItem(Icons.home_outlined, '$roomCount 单元'),
            const Spacer(),
            onDrag,
          ],
        ),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.badgeGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '运行中',
        style: TextStyle(
          color: AppColors.badgeGreenText,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class AddBuildingForm extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();
  final _nameFieldKey = GlobalKey<FormBuilderFieldState>();

  @override
  Widget build(BuildContext context) {
    var initialValue = context.read<Map<String, dynamic>?>() ?? {};
    Printer.info(initialValue);
    return Scaffold(
      appBar: AppBar(
        title: Text("新增楼"),
      ),
      body: SingleChildScrollView(
        child: FormBuilder(
            key: _formKey,
            initialValue: initialValue,
            child: Container(
              margin: EdgeInsets.only(left: 10, top: 10, right: 10),
              child: Column(
                children: [
                  FormBuilderTextField(
                    key: _nameFieldKey,
                    name: 'name',
                    decoration: const InputDecoration(
                        labelText: '建筑名称',
                        icon: Icon(
                          Icons.title,
                          color: Colors.blue,
                        )),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  MaterialButton(
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      // Validate and save the form values
                      var validate = _formKey.currentState?.saveAndValidate();
                      debugPrint(_formKey.currentState?.value.toString());
                      if (!(validate ?? false)) {
                        return;
                      }
                      var val = _formKey.currentState?.value;
                      if (val == null) {
                        return;
                      }
                      Navigator.pop(context, val);
                    },
                    child: const Text('提交'),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
