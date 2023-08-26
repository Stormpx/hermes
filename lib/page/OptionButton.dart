

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/App.dart';
import 'package:hermes/page/import/Import.dart';
import 'package:hermes/page/import/ImportModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../kit/Util.dart';

class Model extends ChangeNotifier{


  String getDataEncoded(){
    var data={};
    App.sharedPreferences!.getKeys()
        .forEach((element) {
      var v=App.sharedPreferences!.getString(element);
      data[element]=v;
    });

    var r = GZipEncoder().encode(utf8.encode(jsonEncode(data)));
    if(r==null){
      return "";
    }
    var str=base64.encode(r);

    Printer.printMapJsonLog(str);

    return str;
  }

  void export2clipboard(BuildContext context){
    var str=getDataEncoded();
    Clipboard.setData(ClipboardData(text: str));
    Toast.show("复制成功 数据长度:${str.length}", duration: 2,gravity: Toast.bottom);
  }

  Future<void> export2File(BuildContext context) async {
    var status=await Permission.storage.request();
    if(!status.isGranted){
      return;
    }

    var str=getDataEncoded();
    var file=File("/storage/emulated/0/Downloads/hermes/${Util.formatDay(DateTime.now())}.hermes");
    var d = file.parent;
    if(! await d.exists())
      await d.create(recursive: true);
    await file.writeAsString(str);

    Printer.printMapJsonLog(file.path);
    Toast.show("导出成功 路径:${file.path}", duration: 5,gravity: Toast.bottom);


  }

  /// only for test
  void clearData(BuildContext context) async{
    await App.sharedPreferences!.clear();
    Toast.show("数据已清除", duration: 2,gravity: Toast.bottom);
  }

  void route2Import(BuildContext context) async{
    await Navigator.push(context, MaterialPageRoute(
        builder: (c)=>ChangeNotifierProvider(
          create: (c)=>ImportModel(),
          child: Import(),
        )
    ));
  }

}


class OptionButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Model>(
      create: (ctx)=>Model(),
      child: Consumer<Model>(
        builder: (ctx,model,child){
          return PopupMenuButton(
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
          );
        },
      ),
    );
    return Container();
  }

}