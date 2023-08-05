import 'package:flutter/material.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/model/FeeResult.dart';
import 'package:hermes/page/snapshot/RoomSnapshotModel.dart';
import 'package:provider/provider.dart';

import 'package:hermes/component/FeeItemDataTable.dart';

class RoomSnapshotPage extends StatefulWidget {
  @override
  _RoomSnapshotPageState createState() => _RoomSnapshotPageState();
}

class _RoomSnapshotPageState extends HermesState<RoomSnapshotPage> {

  int _currentIndex=-1;
  @override
  Widget build(BuildContext context) {

    var model=Provider.of<RoomSnapshotModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("${model.room.name} 记录"),
      ),
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          expansionCallback: (index,bool){
            print("$index, $bool");
            _currentIndex=index;
            if(bool)
              _currentIndex=-1;
            model.notifyListeners();
          },
          children: _buildExpansionPanel(model.getSnapshot()),

        ),
      ),
    );
  }


  List<ExpansionPanel> _buildExpansionPanel(List<FeeSnapshot> list){
    int index=0;
    return list.map((e){
      bool isExpanded=_currentIndex==index++;
      return ExpansionPanel(
          headerBuilder: (index,opened)=>ListTile(
            title:Text("${Util.formatDay(e.date)}:::${e.total}元",
              style: TextStyle(),
            ),
            subtitle: Text("${e.rent}租金::${e.electFee??0}元/度::${e.waterFee??0}元/升"),
            selected: opened,
          ),
          canTapOnHeader: true,
          body: Container(
            color: Colors.grey,
            child: new Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Container(
                alignment: Alignment.center,
                child: FeeItemDataTable(
                  rowHeight: 63,
                  items: e.items??[],
                  fontSize: 14,
                )
//                child: _buildTable(e.items)
              ),
            ),
          ),
          isExpanded: isExpanded
      );

    }).toList();
  }


}


