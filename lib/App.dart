import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/model/Database.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
class App {

  static final String _hermesVersionKey="hermes:version";

  static final String _hermesKeyPrefix="hermes:data:";

  static PackageInfo? packageInfo;

  static SharedPreferences? sharedPreferences;

  static Directory? directory;

  static Directory? exDirectory;

  static Directory? downloadDirectory;

  static HermesDatabase? _database=HermesDatabase();

  static Future<Directory?> _getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) directory = await getExternalStorageDirectory();
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory;
  }

  static Future init() async {
    packageInfo = await PackageInfo.fromPlatform();
    sharedPreferences = await SharedPreferences.getInstance();
    directory = await getApplicationDocumentsDirectory();

    exDirectory = (await getExternalStorageDirectory())!;
    downloadDirectory=Directory("${(await _getDownloadPath())!.path}/hermes/");

    var version=sharedPreferences!.getString(_hermesVersionKey);
    if(version==null){
      setCurrentVersion();
    }

    print(dataVersion);
    print(appVersion);
    print(directory);
    print(exDirectory);
    print(downloadDirectory);
    print(await getExternalCacheDirectories());


  }



  static void setCurrentVersion(){
    sharedPreferences!.setString(_hermesVersionKey, packageInfo!.version);
  }

  static Directory dir({String? dir}){
    return Directory(Uri.file(downloadDirectory!.path).resolve(dir??"").toFilePath(windows: Platform.isWindows));
  }

  static Future<bool> grantStoragePermission() async{
    if(Platform.isAndroid){
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      if(androidInfo.version.sdkInt>=30){
        var status=await Permission.manageExternalStorage.request();
        if(status.isGranted){
          return true;
        }
      }
      var status = await Permission.storage.request();
      return status.isGranted;
    }
    return false;
  }

  static Future<void> switchDatabase(File file)async{
    final dbFolder = await getApplicationDocumentsDirectory();
    var rand = Random.secure();
    var filename = "tmp-${List.generate(10, (index) => rand.nextInt(10)).join()}.sqlite";
    print(p.join(dbFolder.path,filename));
    var db = await file.copy(p.join(dbFolder.path,filename));
    var database = HermesDatabase(db);
    try {
      await database.customStatement("select count(*) from hermes");
      await database.close();
      await _database!.close();
      var hermesDbFile = await databaseFile();
      await hermesDbFile.delete();
      await db.rename(hermesDbFile.path);
      exitApp();
    } catch (e) {
      await db.delete();
      await database.close();
      throw e;
    }

  }

  static void exitApp(){
    if(Platform.isAndroid){
      SystemNavigator.pop();
    }else{
      exit(0);
    }
  }

  static Ver get dataVersion => Ver(sharedPreferences!.getString(App._hermesVersionKey)??"0.0.0");

  static Ver get appVersion => Ver(packageInfo!.version);

  static String get hermesKeyPrefix => _hermesKeyPrefix;


  static HermesDatabase get database => _database!;

}

class Ver implements Comparable<Ver>{
  String version;

  Ver(this.version);

  @override
  int compareTo(Ver other) {
    return _getExtendedVersionNumber(version).compareTo(_getExtendedVersionNumber(other.version));
  }

  bool operator <(other)=> compareTo(other)<0;
  @override
  bool operator ==(covariant Ver other)=> compareTo(other)==0;

  bool operator <=(other)=> this<other||this==other;

  bool operator >(other) => !(this<=other);

  bool operator >=(other) => !(this<other);

  int _getExtendedVersionNumber(String version) {
    List versionCells = version.split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }

  @override
  String toString() {
    return 'Ver{version: $version}';
  }
}