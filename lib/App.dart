import 'dart:io';

import 'package:flutter_printer/flutter_printer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App {

  static SharedPreferences _sharedPreferences;

  static Directory _directory;

  static Directory _exDirectory;



  static Future init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _directory = await getApplicationDocumentsDirectory();
    _exDirectory = await getExternalStorageDirectory();
    Printer.printMapJsonLog(_exDirectory==null);
  }


  static SharedPreferences get sharedPreferences => _sharedPreferences;

  static Directory get directory => _directory;

  static Directory get exDirectory => _exDirectory;
}