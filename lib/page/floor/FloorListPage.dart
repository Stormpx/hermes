import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hermes/component/CardColumnWidget.dart';
import 'package:hermes/component/FloatButton.dart';
import 'package:hermes/component/FullCoverOpaque.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/page/room/RoomDetail.dart';
import 'package:provider/provider.dart';
import 'FloorModel.dart';

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
    // For sharing images coming from outside the app while the app is in the memory
  }



  ///楼层列表
  Widget _floorBuilder(FloorModel model) {
    var list = model.list;
//    print(list);
    return SlidableAutoCloseBehavior(
      child: ReorderableListView.builder(
        scrollDirection: Axis.vertical,
        scrollController: _scrollController,
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          var floorWithRooms = list[index];
          var key = ObjectKey(floorWithRooms.floor.name);
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
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            return _floorForm(
                                initValue: {"name": floorWithRooms.floor.name},
                                onSubmit: (data) async {
                                  var name = data["name"] as String;
                                  if (await model.updateFloor(
                                      floorWithRooms.floor.id!, name)) {
                                    Navigator.of(context).pop();
                                  }
                                });
                          });
                    }),
                SlidableAction(
                    label: '删除',
                    backgroundColor: Colors.red,
                    icon: Icons.delete,
                    onPressed: (BuildContext context) async {
                      var confirm = await showDeleteConfirmDialog([
                        Text("您确定要删除楼层 ${floorWithRooms.floor.name} 吗?"),
                        Text("删除也会将套间一并删除")
                      ]);
                      if (confirm ?? false) {
                        model.deleteFloor(floorWithRooms);
                      }
                    })
              ],
            ),
            child: ExpansionTile(
              subtitle: Text("现有${floorWithRooms.rooms.length}个套间"),

              trailing: FractionallySizedBox(
                widthFactor: 0.21,
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return _roomForm(
                                    title: "新增套间",
                                    onSubmit: (data) async {
                                      if (await model.addRoom(
                                          floorWithRooms.floor.id!,
                                          data["name"] as String)) {
                                        Navigator.of(context).pop();
                                      }
                                    });
                              });
                        }),
                    ReorderableDragStartListener(
                      index: index,
                      child: Icon(Icons.list),
                    ),
                  ],
                ),
              ),
              title: Text(
                floorWithRooms.floor.name,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: 18.0),
              ),
              onExpansionChanged: (expand) {
                model.selectFloor(!expand ? null : floorWithRooms.floor);
              },
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (ctx, index) {
                    var room = floorWithRooms.rooms[index];
                    return ListTile(
                      title: Text(
                        room.name,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      isThreeLine: true,
                      subtitle: Text(
                          "${room.rent ?? 0}  ${room.electFee ?? 0}元/度   ${room.waterFee ?? 0}元/吨"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_attributes_outlined),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (ctx) => _roomForm(
                                      title: "编辑套间名称",
                                      initValue: {"name": room.name},
                                      onSubmit: (data) async{
                                        if(await model.updateRoom(room.id!,data["name"]as String)){
                                          Navigator.of(context).pop();
                                        }
                                      }
                                  ));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_outlined),
                            onPressed: () async {
                              var confirm = await showDeleteConfirmDialog([
                                Text("您确定要删除套间 ${room.name} 吗?"),
                              ]);
                              if (confirm ?? false) {
                                model.delRoom(floorWithRooms,room);
                              }
                            },
                          )
                        ],
                      ),
                      onTap: (){
                        _enterRoom(model,room);
                      },
                    );
                  },
                  itemCount: floorWithRooms.rooms.length,
                )
              ],
            ),
          );
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

  void _enterRoom(FloorModel model,Room room) async{
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (c) => RoomDetail(),
          settings: RouteSettings(arguments: {"roomId": room.id,"name":room.name})),
    );
    model.reloadRoomInFloor(room.floorId,room.id!);
  }


  @override
  Widget build(BuildContext context) {
    var param =
        (ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>);
    Printer.printMapJsonLog(param);
    var id = param["buildingId"] as int;
    var name = param["name"] as String?;
    return ChangeNotifierProvider(
      create: (c) => FloorModel(id),
      child: Consumer<FloorModel>(
        builder: (ctx, model, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
//        resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text(name??"楼层列表"),
            ),
            floatingActionButton: FloatButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return _floorForm(onSubmit: (data) async {
                        var name = data["name"] as String;
                        if (await model.addFloor(name)) {
                          Navigator.of(context).pop();
                        }
                      });
                    });
              },
            ),
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(blankNode); //关键盘
                  // Slidable.of(context)?.close();
                },
                child: _floorBuilder(model)),
          );
        },
      ),
    );
  }

  final _formKey = GlobalKey<FormBuilderState>();
  final _nameFieldKey = GlobalKey<FormBuilderFieldState>();

  Widget _floorForm(
      {Map<String, dynamic>? initValue,
      required void Function(Map<String, dynamic>) onSubmit}) {
    return Dialog(
      insetPadding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            alignment: Alignment.center,
            child: CardColumnWidget(
                child: FormBuilder(
                    key: _formKey,
                    initialValue: initValue ?? {},
                    child: Container(
                      height: 250,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              "输入楼层名称",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                height: 1.0,
                                // letterSpacing: 1.0
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            child: FormBuilderTextField(
                              key: _nameFieldKey,
                              name: "name",
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(errorText: "名称必填"),
                              ]),
                              autofocus: true,
                              maxLines: 1,
                              decoration: InputDecoration(
                                labelText: "楼层名称",
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.blue, width: 2.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.blue, width: 2.0)),
                                errorBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
                              ),
                            ),
                          ),
                          // SizedBox(height: 20),
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 150,
                                  height: 40,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade400,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "取消",
                                        style: TextStyle(
                                          fontSize: 17.0,
                                          height: 1.0,
                                        ),
                                      )),
                                ),
                                SizedBox(width: 20),
                                Container(
                                  width: 150,
                                  height: 40,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(),
                                      onPressed: () async {
                                        // Validate and save the form values
                                        var validate =
                                        _formKey.currentState?.saveAndValidate();
                                        debugPrint(
                                            _formKey.currentState?.value.toString());
                                        if (!(validate ?? false)) {
                                          return;
                                        }
                                        var val = _formKey.currentState?.value;
                                        if (val == null) {
                                          return;
                                        }
                                        onSubmit(val);
                                      },
                                      child: Text(
                                        "确定",
                                        style: TextStyle(
                                          fontSize: 17.0,
                                          height: 1.0,
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))),
          )
        ],
      ),
    );
  }

  Widget _roomForm(
      {String? title,
      Map<String, dynamic>? initValue,
      required void Function(Map<String, dynamic>) onSubmit}) {
    return Dialog(
      insetPadding: EdgeInsets.all(10),
      child:Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Container(
          alignment: Alignment.center,
          child: CardColumnWidget(
              child: FormBuilder(
                  key: _formKey,
                  initialValue: initValue ?? {},
                  child: Container(
                    height: 250,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            title ?? "输入套间名称",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              height: 1.0,
                              // letterSpacing: 1.0
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: FormBuilderTextField(
                            key: _nameFieldKey,
                            name: "name",
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: "名称必填"),
                            ]),
                            autofocus: true,
                            maxLines: 1,
                            decoration: InputDecoration(
                              labelText: "套间名称",
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.red, width: 2.0)),
                            ),
                          ),
                        ),
                        // SizedBox(height: 20),
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 150,
                                height: 40,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade400,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "取消",
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        height: 1.0,
                                      ),
                                    )),
                              ),
                              SizedBox(width: 20),
                              Container(
                                width: 150,
                                height: 40,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(),
                                    onPressed: () async {
                                      // Validate and save the form values
                                      var validate =
                                      _formKey.currentState?.saveAndValidate();
                                      debugPrint(
                                          _formKey.currentState?.value.toString());
                                      if (!(validate ?? false)) {
                                        return;
                                      }
                                      var val = _formKey.currentState?.value;
                                      if (val == null) {
                                        return;
                                      }
                                      onSubmit(val);
                                    },
                                    child: Text(
                                      "确定",
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        height: 1.0,
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))),
        )],
      ),
    );
  }
}
