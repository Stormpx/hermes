import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermes/FloatButton.dart';
import 'package:hermes/InitializingWidget.dart';
import 'package:hermes/page/import/ImportModel.dart';
import 'package:provider/provider.dart';

class Import extends StatefulWidget {
  @override
  _ImportState createState() => _ImportState();
}

class _ImportState extends State<Import> {
  final FocusNode blankNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController configController = TextEditingController();


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
        onPressed: () => model.importConfig(context,configController.text),

      ),
      body: InitializingWidget(
        initialized: model.total<=0,
        loadingText: Text("读取数据${model.total}条 正在处理 ${model.index}/${model.total} "),
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
                            model.setWay(value);
                          }),
                        ),
                        Flexible(
                          child: RadioListTile<int>(title: Text("文件路径"),value: 1, groupValue: model.way, onChanged: (value){
                            model.setWay(value);
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
                  ],
                )
              )
          );
        },
      )
    );
  }
}
