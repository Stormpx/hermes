import 'package:flutter/material.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/App.dart';
import 'package:hermes/page/floor/FloorListPage.dart';
import 'package:hermes/page/floor/Model.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';



void main() {
  Printer.enable=false;
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting()
      .then((_) =>  App.init())
      .then((_) => runApp(
          ChangeNotifierProvider(
            create: (c)=>Model(),
            child: MyApp(),
          )
      ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.



  @override
  Widget build(BuildContext context) {
    /*var p=Provider(FloorListPage(
        list: [
          Floor(
            id:Uuid().v4(),

          )
        ],
        addFloor: null,
        enterFloor: null)
    );*/

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
      home: FloorListPage(),
    );
  }
}

