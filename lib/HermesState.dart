import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

abstract class HermesState<T extends StatefulWidget> extends State<T>{


  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  Future<bool?> showDeleteConfirmDialog(List<Widget> children) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(false), // 关闭对话框
            ),
            TextButton(
              child: Text("删除"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}