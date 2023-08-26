

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/App.dart';
import 'package:hermes/kit/Util.dart';
import 'package:toast/toast.dart';

class ExtOptModel extends ChangeNotifier{



  Future<void> exportDatabase() async{
    var dir = App.dir();
    var random =Random.secure();
    var id =List.generate(8, (index) => random.nextInt(10)).join();

    var file = File("${dir.path}${Util.formatDay(DateTime.now())}-${id}.hermes.db");
    var d = file.parent;
    if(!await d.exists())
      await d.create(recursive: true);

    Printer.printMapJsonLog(file.path);

    App.database.customStatement("VACUUM INTO ?",[file.path]);

    Toast.show("导出成功 路径:${file.path}", duration: 3,gravity: Toast.bottom);
  }

  Future<void> clearData(){
    return App.database.deleteEverything();
  }

}