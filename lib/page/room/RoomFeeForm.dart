import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hermes/page/room/Model.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

enum FieldType{
  Money,
  Meter
}

class RoomFeeForm extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormBuilderState>();
  final _electMetersFieldKey = GlobalKey<FormBuilderFieldState>();
  final _waterMetersFieldKey = GlobalKey<FormBuilderFieldState>();
  final _rentFieldKey = GlobalKey<FormBuilderFieldState>();
  final _electFieldKey = GlobalKey<FormBuilderFieldState>();
  final _waterFieldKey = GlobalKey<FormBuilderFieldState>();

  final _subFormKey = GlobalKey<FormBuilderState>();



  Widget _formFeeField(
      {
        Key? key,
        required String name,
        required String title,
        String unit = "元",
        FieldType fieldType=FieldType.Money
      }) {
    var regExp = fieldType == FieldType.Money ? RegExp(r'[.0-9\-]') : RegExp(r'[0-9]');
    var validators = [
      FormBuilderValidators.required(errorText: "该项必填"),

    ];
    if(fieldType==FieldType.Meter){
      validators.add(FormBuilderValidators.min(0,errorText: "必须大于等于1"));
    }else{
      validators.add(FormBuilderValidators.numeric(errorText: "必须是有效的数值"));
    }
    return FormBuilderTextField(
      key: key,
      name: name,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(regExp)
      ],
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: "该项必填"),
        FormBuilderValidators.numeric(errorText: "必须是有效的数值"),
        FormBuilderValidators.min(0,errorText: "必须大于等于1"),
      ]),
      onTap: (){
        if(fieldType==FieldType.Money) {
          String? val = _formKey.currentState?.getRawValue(name);
          if (val != null) {
            var v = double.tryParse(val);
            if (v == 0) {
              _formKey.currentState?.fields[name]?.didChange("");
            }
          }
        }
      },
      decoration: InputDecoration(
          labelText: title,
          labelStyle: TextStyle(fontSize: 20),
          suffixText: unit,
          suffixStyle: TextStyle(fontSize: 17, color: Colors.grey.shade700)),
    );
  }

  Widget _optItems(RoomFeeFormModel model) {
    return Flexible(
        child: ReorderableListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      scrollController: _scrollController,
      buildDefaultDragHandles: false,
      itemBuilder: (BuildContext context, int index) {
        var opt = model.optFees[index];
        var key = ObjectKey(opt);
        return Row(
          key: key,
          children: [
            Expanded(child: _formFeeField(name: opt.name, title: opt.name)),
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.list),
            ),
            IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  model.removeOpt(opt);
                }),
          ],
        );
      },
      itemCount: model.optFees.length,
      onReorder: (int oldIndex, int newIndex) {
        model.optReorder(oldIndex, newIndex);
      },
    ));
  }

  //
  // Widget _optItems(RoomFeeFormModel model) {
  //   return Column(
  //     children: [
  //       for (final opt in model.optFees)
  //         Row(
  //           children: [
  //             Expanded(child: _formFeeField(name: opt.name, title: opt.name)),
  //             IconButton(
  //                 icon: Icon(
  //                   Icons.delete,
  //                   color: Colors.red,
  //                 ),
  //                 onPressed: () {
  //                   model.removeOpt(opt);
  //                 }),
  //           ],
  //         )
  //     ],
  //   );
  // }

  Widget _optFeeBlock(BuildContext ctx, RoomFeeFormModel model) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "额外收费项",
            style: TextStyle(
                letterSpacing: 5.0,
                fontSize: 19,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
          _optItems(model),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: FormBuilder(
                key: _subFormKey,
                child: FormBuilderTextField(
                  name: "opt",
                  decoration: InputDecoration(
                    labelText: "收费项名称",
                  ),
                ),
              )),
              TextButton.icon(
                icon: Icon(
                  Icons.add,
                  color: Colors.red,
                ),
                label: Text(
                  "新增",
                  style: TextStyle(fontSize: 17, color: Colors.red),
                ),
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      side: BorderSide(color: Colors.red.shade400),
                      borderRadius: BorderRadius.circular(18.67))),
                ),
                onPressed: () {
                  var state = _subFormKey.currentState;
                  if (state?.saveAndValidate() ?? false) {
                    var opt = state?.value["opt"] as String;
                    model.addOpt(opt);
                    state?.reset();
                    FocusScope.of(ctx).unfocus();
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  bool exit=false;
  DateTime? currentBackPressTime;

  Future<bool> onWillTap() async{
    if(exit){
      return true;
    }
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Toast.show("再操作一次返回");
      return false;
    }

    return true;
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<RoomFeeFormModel>(
      builder: (ctx, model, child) {
        ToastContext().init(ctx);
        return WillPopScope(
          onWillPop: onWillTap,
          child: Scaffold(
            appBar: AppBar(
              title: Text("修改套间设置"),
            ),
            body: SingleChildScrollView(
              child: FormBuilder(
                  key: _formKey,
                  initialValue: model.initFormValue(),
                  child: Container(
                    margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                    child: Column(
                      children: [
                        _formFeeField(
                            key: _electMetersFieldKey, name: 'electMeters', title: '电表',unit: "个"),
                        const SizedBox(height: 10),
                        _formFeeField(
                            key: _waterMetersFieldKey, name: 'waterMeters', title: '水表',unit: "个"),
                        const SizedBox(height: 10),
                        _formFeeField(
                            key: _rentFieldKey, name: 'rent', title: '租金'),
                        const SizedBox(height: 10),
                        _formFeeField(
                            key: _electFieldKey, name: 'elect', title: '电费',unit: "(元/度)"),
                        const SizedBox(height: 10),
                        _formFeeField(
                            key: _waterFieldKey, name: 'water', title: '水费',unit: "(元/度)"),
                        const SizedBox(height: 10),
                        _optFeeBlock(ctx, model),
                        MaterialButton(
                          color: Colors.blueAccent,
                          onPressed: () async {
                            // Validate and save the form values
                            var validate =
                            _formKey.currentState?.saveAndValidate();
                            debugPrint(_formKey.currentState?.value.toString());
                            if (!(validate ?? false)) {
                              return;
                            }
                            var val = _formKey.currentState?.value;
                            if (val == null) {
                              return;
                            }
                            await model.submit(val);
                            Navigator.pop(context,true);
                          },
                          child: const Text('提交'),
                        )
                      ],
                    ),
                  )),
            ),
          ),
        );
      },
    );
  }
}
