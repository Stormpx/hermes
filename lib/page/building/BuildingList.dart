

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_printer/flutter_printer.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hermes/HermesState.dart';
import 'package:hermes/component/FloatButton.dart';
import 'package:hermes/model/Database.dart';
import 'package:hermes/model/Repository.dart';
import 'package:hermes/page/OptionButton.dart';
import 'package:hermes/page/building/BuildingListModel.dart';
import 'package:hermes/page/floor/FloorListPage.dart';
import 'package:hermes/page/floor/FloorModel.dart';
import 'package:provider/provider.dart';

class BuildingListPage extends StatefulWidget {

  @override
  _BuildingListState createState() => _BuildingListState();

}


class _BuildingListState extends HermesState<BuildingListPage> {
  final FocusNode blankNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  OverlayEntry? overlayEntry;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx)=>BuildingListModel(),
      child: Consumer<BuildingListModel>(
        builder: (ctx,model,child){
          return Scaffold(
            resizeToAvoidBottomInset: false,
//        resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text("楼列表"),
              actions: <Widget>[
                OptionButton()
              ],
            ),
            floatingActionButton: FloatButton(
              onPressed: () {
                addNewBuilding(model);
              },
            ),
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(blankNode); //关键盘
                },
                child: buildingList(model)
            ),
          );
        },
      )
    );

  }


  Widget buildingList(BuildingListModel model){
    var list = model.buildings;
    return ReorderableListView.builder(
      scrollDirection: Axis.vertical,
      scrollController: _scrollController,
      buildDefaultDragHandles: false,
      itemBuilder: (context,index){
        var building = list[index];
        var key = ObjectKey(building.name);
        return ListTile(
          key: key,
          subtitle: Text("placeholder"),
          trailing: ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.list),
          ),
          title: Text(
            building.name,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(fontSize: 18.0),
          ),
          onTap: () => enterBuilding(context,building),
        );
      },
      itemCount: list.length,
      onReorder: (oldIndex,newIndex){
        Printer.printMapJsonLog("$oldIndex------$newIndex");
        model.buildingReorder(oldIndex,newIndex);
      },
      physics: ClampingScrollPhysics(),
    );
  }

  void enterBuilding(BuildContext context,Building building) async{
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (c)=>FloorListPage()),
    );
  }

  void addNewBuilding(BuildingListModel model) async {
    Map<String,dynamic>? r = await Navigator.push(
      context,
      MaterialPageRoute(builder: (c)=>AddBuildingForm()),
    );

    if(r!=null){
      model.saveNewBuilding(Building(name: r["name"] as String));
    }

  }

}

class AddBuildingForm extends StatelessWidget{

  final _formKey = GlobalKey<FormBuilderState>();
  final _nameFieldKey = GlobalKey<FormBuilderFieldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("新增楼"),
      ),
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                key: _nameFieldKey,
                name: 'name',
                decoration: const InputDecoration(labelText: '楼名称'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              const SizedBox(height: 10),
              MaterialButton(
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  // Validate and save the form values
                  var validate = _formKey.currentState?.saveAndValidate();
                  debugPrint(_formKey.currentState?.value.toString());
                  if(!(validate??false)){
                    return;
                  }
                  var val = _formKey.currentState?.value;
                  if(val==null){
                    return;
                  }
                  Navigator.pop(context,val);

                },
                child: const Text('提交'),
              )
            ],
          ),
        ),
      ),
    );
  }

}
