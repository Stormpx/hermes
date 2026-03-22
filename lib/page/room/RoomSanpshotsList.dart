import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/model/Data.dart';
import 'package:hermes/page/room/Model.dart';
import 'package:hermes/page/room/RoomBill.dart';
import 'package:provider/provider.dart';


class RoomSnapshotList extends StatefulWidget {
  @override
  _RoomSnapshotListState createState() => _RoomSnapshotListState();
}

class _RoomSnapshotListState extends HermesState<RoomSnapshotList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RoomSnapshotModel>(
      builder: (ctx, model, child) {
        return ListView.builder(
          itemCount: model.records.length,
          itemBuilder: (context, index) {
            return _buildListItem(model, model.records[index]);
          },
        );
      },
    );
  }

  Widget _buildListItem(RoomSnapshotModel model, RoomSnapshotRecord e) {
    var key = ObjectKey(e);
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
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt_long,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          "${e.startDate} - ${e.endDate}",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                "¥${e.snapshot.totalAmount ?? 0}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "租金 ${e.snapshot.rent ?? 0}",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          final fee = FeeResult.fromSnapshotRecord(model.name, e);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => RoomBill(),
              settings: RouteSettings(arguments: {"roomId": model.id, "feeResult": fee}),
            ),
          );
        },
      ),
    );
  }
}
