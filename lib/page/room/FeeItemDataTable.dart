import 'package:flutter/material.dart';
import 'package:hermes/page/room/Model.dart';

class FeeItemDataTable extends StatelessWidget {

  List<FeeItem> items;
  double rowHeight;
  double fontSize;


  FeeItemDataTable({required this.items,this.fontSize=10,this.rowHeight=48.0});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      dataRowMinHeight: this.rowHeight,
      dataRowMaxHeight: this.rowHeight,
      columns: [
        DataColumn(label: _str('收费项')),
        DataColumn(label: _str('收费(元)'), numeric: false),
      ],
      rows: items.map((e) => _buildDataRow(e.name!, e.desc??e.fee.toStringAsFixed(2))).toList(),
    );
  }

  DataRow _buildDataRow(String name,String str){
    return DataRow(cells: [
      DataCell(_str(name)),
      DataCell(_str(str)),
    ]);
  }

  Widget _str(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: this.fontSize),
    );
  }
}
