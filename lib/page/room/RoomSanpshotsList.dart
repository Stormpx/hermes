import 'package:flutter/material.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/kit/Util.dart';
import 'package:hermes/model/Data.dart';
import 'package:hermes/page/room/Model.dart';
import 'package:provider/provider.dart';

import 'package:hermes/page/room/FeeItemDataTable.dart';

class RoomSnapshotList extends StatefulWidget {
  @override
  _RoomSnapshotListState createState() => _RoomSnapshotListState();
}

class _RoomSnapshotListState extends HermesState<RoomSnapshotList> {
  int _currentIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomSnapshotModel>(
      builder: (ctx, model, child) {
        return SingleChildScrollView(child: _snapshotRecords(model));
      },
    );
  }

  Widget _snapshotRecords(RoomSnapshotModel model) {
    return ExpansionPanelList(
        expansionCallback: (index, bool) {
          _currentIndex = index;
          if (!bool) _currentIndex = -1;
          model.notifyListeners();
        },
        children: _buildExpansionPanel(model));
  }


  List<ExpansionPanel> _buildExpansionPanel(RoomSnapshotModel model) {
    var list = model.records;
    int index = 0;
    return list.map((e) {
      var key = ObjectKey(e);
      bool isExpanded = _currentIndex == index++;
      return ExpansionPanel(
          headerBuilder: (index, opened) {
            return Slidable(
              key: key,
              startActionPane: ActionPane(
                motion: ScrollMotion(),
                children: [
                  SlidableAction(
                      label: '删除',
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                      onPressed: (BuildContext context) async {
                        var confirm = await showDeleteConfirmDialog([
                          Text("${e.endDate} - ${e.startDate}"),
                          Text("您确定要删除该记录吗?"),
                        ]);
                        if (confirm ?? false) {
                          model.deleteRecord(e);
                        }
                      })
                ],
              ),
              child: ListTile(
                title: Text(
                  "${e.startDate}:::${e.snapshot.totalAmount}元",
                  style: TextStyle(),
                ),
                subtitle: Text(
                    "${e.snapshot.rent}租金::${e.snapshot.electFee ?? 0}元/度::${e.snapshot.waterFee ?? 0}元/升"),
                selected: opened,
              ),
            );
          },
          canTapOnHeader: true,
          body: _snapshotForm(e),
          isExpanded: isExpanded);
    }).toList();
  }

  Widget _snapshotForm(RoomSnapshotRecord record) {
    return Container(
      color: Colors.grey,
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
            padding: EdgeInsets.only(top: 5),
            alignment: Alignment.center,
            child: Column(
              children: [
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
  }
}
