import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/component/CardColumnWidget.dart';
import 'package:hermes/component/FloatButton.dart';
import 'package:hermes/component/FullCoverOpaque.dart';
import 'package:hermes/HermesState.dart';
import 'package:provider/provider.dart';
import 'FloorModel.dart';


class FloorListPage extends StatefulWidget {



  @override
  _FloorListPageState createState() => _FloorListPageState();

}



class _FloorListPageState extends HermesState<FloorListPage> {
  final FocusNode blankNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  TextEditingController floorNameController = TextEditingController();
  TextEditingController floorSortController = TextEditingController();

  bool _input= false;


  @override
  void initState() {
    super.initState();
    // For sharing images coming from outside the app while the app is in the memory
  }

  ///楼层列表
  Widget _floorBuilder(FloorModel model){
    var list=model.list;
//    print(list);
    return ReorderableListView.builder(
      scrollDirection: Axis.vertical,
        scrollController: _scrollController,
        buildDefaultDragHandles: false,
        itemBuilder: (context,index){
          var floor = list[index];
          var key = ObjectKey(floor.name);
          return ListTile(
            key: key,
            subtitle: Text("placeholder"),
            trailing: ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.list),
            ),
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
    return ChangeNotifierProvider(
      create: (c)=>FloorModel(),
      child: Consumer<FloorModel>(
        builder: (ctx,model,child){
          return Scaffold(
            resizeToAvoidBottomInset: false,
//        resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text("楼层列表"),
            ),
            floatingActionButton: FloatButton(
              onPressed: () => setState((){ _input = true;}),
            ),
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(blankNode); //关键盘
                },
                child: _floorBuilder(model)
            ),
          );
        },
      ),
    );

  }

  Widget _inputFloorWidget() {
//    print( MediaQuery.of(context).viewInsets.bottom);
    var model=Provider.of<FloorModel>(context,listen: false);
//    model.s();
    var floor=model.currFloor;
    if(floor!=null){
      floorNameController.text=floor.name;
    }
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
                                onPressed: ()=>setState((){
                                  model.selectFloor(null);
                                  _input=false;
                                  floorNameController.clear();
                                })
                            ),
                          ),
                        )
                    ),

                    Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: (){
                                _input=false;
                                var text=floorNameController.text;
                                floorNameController.clear();

                                if(floor==null){
                                  model.onAddFloor(context,text);
                                }else{
                                  model.onEditFloor(context,text);
                                }

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
                  controller: floorNameController,
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
