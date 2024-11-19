import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:hermes/App.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/component/FloatButton.dart';
import 'package:hermes/component/InitializingWidget.dart';
import 'package:hermes/page/import/ImportModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class Import extends StatefulWidget {
  @override
  _ImportState createState() => _ImportState();
}

class _ImportState extends HermesState<Import> {
  final FocusNode blankNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController configController = TextEditingController();


  void _chooseFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if(result != null) {
      Printer.printMapJsonLog(result.files.single.path);

      configController.text=result.files.single.path!;

    } else {
      // User canceled the picker
    }

  }

  @override
  Widget build(BuildContext context) {
    var model=Provider.of<ImportModel>(context,listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("导入数据"),
      ),
      floatingActionButton: FloatButton(
        icon: Icon(
          Icons.games,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () async{
          try {
            await model.importConfig(configController.text);
            Toast.show("数据导入完毕", duration: 2,gravity: Toast.bottom);
            Navigator.pop(context);
          } catch (e) {
            Toast.show("导入失败..");
          }
        },

      ),
      body: InitializingWidget(
        initialized: !model.importing,
        loadingText: Text("导入数据中"),
        builder: (){
          return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(blankNode); //关键盘
              },
              child: Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: RadioListTile<int>(title: Text("黏贴数据"),value: 0, groupValue: model.way, onChanged: (value){
                            model.setWay(value!);
                          }),
                        ),
                        Flexible(
                          child: RadioListTile<int>(title: Text("文件路径"),value: 1, groupValue: model.way, onChanged: (value)async{
                            if(!(await App.grantStoragePermission())){
                              Toast.show("获取文件访问权限失败", duration: 2,gravity: Toast.bottom);
                              return;
                            }
                            model.setWay(value!);
                          }),
                        )
                      ],
                    ),
                    TextField(
                      controller: configController,
                      maxLines: null,
                      style: TextStyle(fontSize: 20,),
                      keyboardType: TextInputType.multiline,
                    ),
                    Container(
                      child: model.way!=1?null:ElevatedButton(
                        onPressed: () => _chooseFile(),
                        child: Text("选择文件"),
                      ),
                    )
                  ],
                )
              )
          );
        },
      )
    );
  }
}
