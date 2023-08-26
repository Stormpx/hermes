import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/App.dart';
import 'package:hermes/page/RebuildPage.dart';
import 'package:hermes/page/building/BuildingList.dart';
import 'package:hermes/page/floor/FloorListPage.dart';
import 'package:hermes/page/floor/FloorModel.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

void main() {
  Printer.enable = true;
  assert(() {
    NativeDatabase.closeExistingInstances();
    return true;
  }());
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting()
      .then((_) => App.init())
      .then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return MaterialApp(
      title: 'Hermes',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: RebuildPage(
        page: BuildingListPage(),
      ),
    );
  }
}
