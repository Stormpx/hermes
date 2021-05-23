import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/CardColumnWidget.dart';
import 'package:hermes/FloatButton.dart';
import 'package:hermes/FullCoverOpaque.dart';
import 'package:provider/provider.dart';
import 'Model.dart';


class FloorListPage extends StatefulWidget {



  @override
  _FloorListPageState createState() => _FloorListPageState();

}



class _FloorListPageState extends State<FloorListPage> {
  final FocusNode blankNode = FocusNode();
  final ScrollController _scrollController = ScrollController();


  bool _addFloor = false;


  @override
  void initState() {
    super.initState();
    // For sharing images coming from outside the app while the app is in the memory
  }

  ///楼层列表
  Widget floorBuilder(){
    var model=Provider.of<Model>(context);
    var list=model.list;
//    print(list);
    return ReorderableListView.builder(
      scrollDirection: Axis.vertical,
        scrollController: _scrollController,
        itemBuilder: (context,index){
          var floor = list[index];
          var key = ObjectKey(floor.name);
          return ListTile(
            key: key,
//            isThreeLine: true,
            subtitle: Text("placeholder"),
            title: Text(
              floor.name,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 18.0),
            ),
            onTap: () => model.onEnterFloor(context,floor),
          );
        },
        itemCount: list.length,
        onReorder: (oldIndex,newIndex){
          Printer.printMapJsonLog("$oldIndex------$newIndex");
          model.floorReorder(oldIndex,newIndex);
        },
        physics: ClampingScrollPhysics(),
    );

//    final List<int> _items = List<int>.generate(50, (int index) => index);
//    final ColorScheme colorScheme = Theme.of(context).colorScheme;
//    final oddItemColor = colorScheme.primary.withOpacity(0.05);
//    final evenItemColor = colorScheme.primary.withOpacity(0.15);
//
//    return ReorderableListView(
//      padding: const EdgeInsets.symmetric(horizontal: 40),
//      children: <Widget>[
//        for (int index = 0; index < _items.length; index++)
//          ListTile(
//            key: Key('$index'),
//            tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
//            title: Text('Item ${_items[index]}'),
//          ),
//      ],
//      onReorder: (int oldIndex, int newIndex) {
//        setState(() {
//          if (oldIndex < newIndex) {
//            newIndex -= 1;
//          }
//          final int item = _items.removeAt(oldIndex);
//          _items.insert(newIndex, item);
//        });
//      },
//    );

//    return ListView.builder(
//
//      controller: _scrollController,
//      shrinkWrap: true,
//      itemBuilder: (context,index){
//        var floor = list[index];
//        var key = ObjectKey(floor.name);
//        return ListTile(
//          key: key,
//          isThreeLine: true,
//          subtitle: Text("placeholder"),
//          title: Text(
//            floor.name,
//            softWrap: false,
//            overflow: TextOverflow.fade,
//            style: TextStyle(fontSize: 18.0),
//          ),
//          onTap: () => model.onEnterFloor(context,floor),
//        );
//      },
//      itemCount: list.length,
//      itemExtent: 60,
//      physics: ClampingScrollPhysics(),
//    );
  }

  @override
  Widget build(BuildContext context) {
    var model=Provider.of<Model>(context,listen: false);
    List<Widget> widgets = [
      Scaffold(
        resizeToAvoidBottomInset: false,
//        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("楼层列表"),
          actions: <Widget>[
            PopupMenuButton(
              itemBuilder: (context){
                return [
                  PopupMenuItem(child: Text("导出到剪切板"),value: "export2clipboard",),
                  PopupMenuItem(child: Text("导出到文件"),value: "export2file",),
                  PopupMenuItem(child: Text("导入"),value: "import"),
                  PopupMenuItem(child: Text("清除数据"),value: "clear"),
                ];
              },
              onCanceled: (){
                print("canceled");
              },
              onSelected: (value){
                switch(value){
                  case "export2clipboard":
                    model.export2clipboard(context);
                    break;
                  case "export2file":
                    model.export2File(context);
                    break;
                  case "import":
                    model.route2Import(context);
                    break;
                  case "clear":
                    model.clearData(context);
                    break;
                }
              },
            )
          ],
        ),
        floatingActionButton: FloatButton(
          onPressed: () => setState(() => _addFloor = true),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(blankNode); //关键盘
          },
          child: floorBuilder()
        ),
      ),
    ];
    if (_addFloor) {
//      _addFloor=false;
      widgets.add(FullCoverOpaque(child: Container()));
      widgets.add(inputFloorWidget());
    }

    return Stack(
      children: widgets,
    );
  }

  Widget inputFloorWidget() {
    print( MediaQuery.of(context).viewInsets.bottom);
    var model=Provider.of<Model>(context,listen: false);
//    model.s();
    return Container(
//      height: MediaQuery.of(context).size.height,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom ),
      child: CardColumnWidget(
          child: Container(
            height: 200,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.lightBlue,
                            ),
                            child: IconButton(
                                icon: Icon(Icons.close,color: Colors.white),
                                onPressed: ()=>setState(()=>_addFloor=false)
                            ),
                          ),
                        )
                    ),

                    Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: FlatButton(
                              onPressed: (){
                                _addFloor=false;
                                model.onAddFloor(context);
                              },
                              child: Text("ADD",
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontSize: 18
                                ),
                              )
                          ),
                        )
                    ),
                  ],
                ),
                TextField(
//                    onSubmitted: (s) {},
                  controller: model.floorNameController,
                  autofocus: true,
                  maxLines: 1,
                  obscureText: false,
                  decoration: InputDecoration(labelText: "楼层名", icon: Icon(Icons.atm)),
                ),
//                TextField(
//                  controller: model.floorSortController,
//                  autofocus: false,
//                  maxLines: 1,
//                  obscureText: false,
//                  keyboardType: TextInputType.numberWithOptions(),
//                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
//                  textInputAction: TextInputAction.done,
//                  decoration: InputDecoration(
//                      labelText: "排序(不填默认99)", icon: Icon(Icons.access_time)),
//                ),
              ],
            ),
          )
      ),
    );
  }
}
