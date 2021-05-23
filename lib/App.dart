import 'dart:io';

import 'package:flutter_printer/flutter_printer.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App {

  static String _version="2.2.1";

  static String _hermesKeyPrefix="hermes:data:";

  static SharedPreferences _sharedPreferences;

  static Directory _directory;

  static Directory _exDirectory;



  static Future init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _directory = await getApplicationDocumentsDirectory();
    _exDirectory = await getExternalStorageDirectory();
    Printer.printMapJsonLog(_exDirectory==null);
    var versionKey="hermes:version";
    var version=_sharedPreferences.getString(versionKey);
    if(version!=null){
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _sharedPreferences.setString(versionKey, packageInfo.version);
    }
  }

  static Directory dir({String dir}){
    return Directory("/storage/emulated/0/hermes/${dir??""}");
  }


  static String get hermesKeyPrefix => _hermesKeyPrefix;

  static SharedPreferences get sharedPreferences => _sharedPreferences;

  static Directory get directory => _directory;

  static Directory get exDirectory => _exDirectory;
}