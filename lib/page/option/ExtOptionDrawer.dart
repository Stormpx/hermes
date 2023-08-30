import 'package:flutter/material.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/page/Rebuild.dart';
import 'package:hermes/page/import/Import.dart';
import 'package:hermes/page/import/ImportModel.dart';
import 'package:hermes/page/option/Model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class ExtOptionDrawer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ExtOptionDrawerState();
  }

}

class ExtOptionDrawerState extends HermesState<ExtOptionDrawer> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => ExtOptModel(),
      child: Consumer<ExtOptModel>(
        builder: (ctx,model,child){
          return Drawer(
            child: ListView(
              children: [
                DrawerHeader(child: Text("123")),
                ListTile(
                  title:
                  Text('导入', style: TextStyle(color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 17)),
                  //CircleAvatar 一般用于设置圆形头像
                  leading: Icon(Icons.import_export_outlined, color: Colors.black,),
                  onTap: () async {

                    _enterImportPage(ctx);
                  },
                ),
                ListTile(
                  title: Text('导出到文件',
                      style: TextStyle(color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 17)),
                  leading: Icon(Icons.import_export_outlined, color: Colors.black,),
                  onTap: () async{
                    var status=await Permission.storage.request();
                    if(!status.isGranted){
                      return;
                    }
                    await model.exportDatabase();
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: Text('清除数据',
                      style: TextStyle(color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 17)),
                  leading: Icon(
                    Icons.cleaning_services_outlined, color: Colors.black,),
                  onTap: () async {
                    var confirm = await showDeleteConfirmDialog([
                      Text("是否确认清除所有数据?")
                    ]);
                    if(confirm??false){
                      await model.clearData();
                    }
                    Navigator.pop(ctx,"clear");
                  },
                ),
                ListTile(
                  title:
                  Text('加载旧数据', style: TextStyle(color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 17)),
                  //CircleAvatar 一般用于设置圆形头像
                  leading: Icon(Icons.sim_card_download_outlined, color: Colors.black,),
                  onTap: () async {
                    showLoaderDialog(context);
                    try {
                      await Rebuild(SharedPreferencesKv()).start();
                    } catch (e) {
                      Printer.error(e);
                    } finally {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }

                  },
                ),
              ],
            ),
          );
        },
      ),
    );

  }

  Future<void> _enterImportPage(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(
        builder: (c) =>
            ChangeNotifierProvider(
              create: (c) => ImportModel(),
              child: Import(),
            )
    ));
    Navigator.pop(ctx);
  }
}
