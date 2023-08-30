import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:toast/toast.dart';

abstract class HermesState<T extends StatefulWidget> extends State<T>{


  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  showLoaderDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return Container(
          alignment: Alignment.center,
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
                color: Colors.white30,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Center(child: CircularProgressIndicator(),)
            )
          ),
        );
      },
    );
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