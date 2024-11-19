import 'dart:async';

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
import 'package:hermes/model/Repository.dart';
import 'package:hermes/page/option/ExtOptionDrawer.dart';
import 'package:hermes/page/building/BuildingListModel.dart';
import 'package:hermes/page/floor/FloorListPage.dart';
import 'package:hermes/page/floor/FloorModel.dart';
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
                    return Scaffold(
                      resizeToAvoidBottomInset: false,
//        resizeToAvoidBottomPadding: false,
                      appBar: AppBar(
                        title: Text("建筑列表"),
                      ),
                      drawer: ExtOptionDrawer(),
                      drawerEdgeDragWidth: MediaQuery.of(context).size.width/2,
                      onDrawerChanged: (open) {
                        if (!open) {
                          model.reload();
                        }
                      },
                      floatingActionButton: FloatButton(
                        onPressed: () {
                          _addNewBuilding(model!);
                        },
                      ),
                      body: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(blankNode); //关键盘
                          },
                          child: buildingList(model!)),
                    );
                  }));
            },
          );
        },
      ),
    );
  }

  Widget buildingList(BuildingListModel model) {
    var list = model.buildings;
    if (!start) {
      start = true;
      if (list.length == 1) {
        Timer(Duration(milliseconds: 300), () {
          _enterBuilding(context, list[0]);
        });
      }
    }
    return SlidableAutoCloseBehavior(
        child: ReorderableListView.builder(
          scrollDirection: Axis.vertical,
          scrollController: _scrollController,
          buildDefaultDragHandles: false,
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
              child: ListTile(
                subtitle: Text("placeholder"),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: Icon(Icons.list),
                ),
                title: Text(
                  building.name,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(fontSize: 18.0),
                ),
                onTap: () => _enterBuilding(context, building),
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

  void _enterBuilding(BuildContext context, Building building) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (c) => FloorListPage(),
          settings: RouteSettings(
              arguments: {"buildingId": building.id, "name": building.name})),
    );
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
      // model.saveNewBuilding(Building(name: r["name"] as String));
    }
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
