import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hermes/page/room/Model.dart';
import 'package:hermes/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

enum FieldType { Money, Meter }

class RoomFeeForm extends StatefulWidget {
  const RoomFeeForm({super.key});

  @override
  State<RoomFeeForm> createState() => _RoomFeeFormState();
}

class _RoomFeeFormState extends State<RoomFeeForm> {
  final ScrollController _scrollController = ScrollController();

  final _formMeteringKey = GlobalKey<FormBuilderState>();
  final _formFixedKey = GlobalKey<FormBuilderState>();
  final _formAddonsKey = GlobalKey<FormBuilderState>();

  final _electMetersFieldKey = GlobalKey<FormBuilderFieldState>();
  final _waterMetersFieldKey = GlobalKey<FormBuilderFieldState>();
  final _rentFieldKey = GlobalKey<FormBuilderFieldState>();
  final _electFieldKey = GlobalKey<FormBuilderFieldState>();
  final _waterFieldKey = GlobalKey<FormBuilderFieldState>();

  final _subFormKey = GlobalKey<FormBuilderState>();

  bool exit = false;
  DateTime? currentBackPressTime;

  Future<bool> onWillTap() async {
    if (exit) {
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

  Widget _formFeeField({
    required GlobalKey<FormBuilderFieldState> key,
    required String name,
    required String title,
    String unit = "元",
    FieldType fieldType = FieldType.Money,
    bool isLarge = false,
  }) {
    var regExp =
        fieldType == FieldType.Money ? RegExp(r'[.0-9\-]') : RegExp(r'[0-9]');
    var validators = [
      FormBuilderValidators.required(errorText: "该项必填"),
    ];
    if (fieldType == FieldType.Meter) {
      validators.add(FormBuilderValidators.min(0, errorText: "必须大于等于0"));
    } else {
      validators.add(FormBuilderValidators.numeric(errorText: "必须是有效的数值"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.1,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            if (fieldType == FieldType.Money && isLarge)
              Text(
                "¥",
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Expanded(
              child: FormBuilderTextField(
                key: key,
                name: name,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(regExp)],
                validator: FormBuilderValidators.compose(validators),
                onTap: () {
                  if (fieldType == FieldType.Money) {
                    String? val = key.currentState?.value as String?;
                    if (val != null) {
                      var v = double.tryParse(val);
                      if (v == 0) {
                        key.currentState?.didChange("");
                      }
                    }
                  }
                },
                style: TextStyle(
                  fontSize: isLarge ? 24 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  // border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHighest,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixText: unit,
                  suffixStyle: TextStyle(
                    fontSize: isLarge ? 14 : 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _optItems(RoomFeeFormModel model) {
    return FormBuilder(
      key: _formAddonsKey,
      initialValue: model.initAddonsFormValue(),
      child: Column(
        children: [
          for (int index = 0; index < model.optFees.length; index++)
            _buildOptItem(model, index),
        ],
      ),
    );
  }

  Widget _buildOptItem(RoomFeeFormModel model, int index) {
    var opt = model.optFees[index];
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "项目名称",
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  opt.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "金额",
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 64,
                      child: FormBuilderTextField(
                        name: opt.name,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[.0-9\-]')),
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: "该项必填"),
                          FormBuilderValidators.numeric(errorText: "必须是有效的数值"),
                        ]),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    Text(
                      "元",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: () {
              model.removeOpt(opt);
            },
          ),
        ],
      ),
    );
  }

  Widget _optForm() {
    return FormBuilder(
        key: _subFormKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: FormBuilderTextField(
              name: "opt",
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: "该项必填"),
              ]),
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "收费项名称",
                hintStyle: TextStyle(
                  color: AppColors.hint,
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            )),
            Expanded(flex: 2,child: Container()),
            Expanded(
              flex: 1,
                child: FormBuilderTextField(
              name: "fee",
              keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[.0-9\-]')),
                ],
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: "该项必填"),
                FormBuilderValidators.numeric(errorText: "必须是有效的数值"),
              ]),
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "0.00",
                hintStyle: TextStyle(
                  color: AppColors.hint,
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            )),
            Text(
              "元",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(width: 32),
          ],
        ));
  }

  Widget _optFeeBlock(BuildContext ctx, RoomFeeFormModel model) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "额外收费项",
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              "Add-ons",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _optItems(model),
        Container(
            margin: EdgeInsets.only(top: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest.withOpacity(0.3),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _optForm()),
        SizedBox(height: 16),
        TextButton.icon(
          icon: Icon(
            Icons.add,
            color: AppColors.secondary,
            size: 18,
          ),
          label: Text(
            "新增",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            var state = _subFormKey.currentState;
            if (state?.saveAndValidate() ?? false) {
              var opt = state?.value["opt"] as String;
              var fee = state?.value["fee"] as String;
              model.addOpt(opt, double.parse(fee));
              state?.reset();
              FocusScope.of(ctx).unfocus();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomFeeFormModel>(
      builder: (ctx, model, child) {
        ToastContext().init(ctx);
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (await onWillTap()) {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.surface,
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.surface,
                  elevation: 0,
                  pinned: true,
                  expandedHeight: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  title: Text(
                    "修改套间设置",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.onSurfaceVariant,
                      ),
                      onPressed: () {
                        // 更多选项功能
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Section
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primary,
                                          AppColors.secondary,
                                          AppColors.primaryFixed,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 24,
                                left: 24,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Unit Settings",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryFixed,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      model.room.name,
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // 仪表配置 Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "仪表配置",
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              "Metering",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FormBuilder(
                            key: _formMeteringKey,
                            initialValue: model.initMeteringFormValue(),
                            child: Column(
                              children: [
                                _formFeeField(
                                  key: _electMetersFieldKey,
                                  name: 'electMeters',
                                  title: '电表数量',
                                  unit: "个",
                                  fieldType: FieldType.Meter,
                                ),
                                SizedBox(height: 24),
                                _formFeeField(
                                  key: _waterMetersFieldKey,
                                  name: 'waterMeters',
                                  title: '水表数量',
                                  unit: "个",
                                  fieldType: FieldType.Meter,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // 标准收费 Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "标准收费",
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              "Fixed Rates",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FormBuilder(
                              key: _formFixedKey,
                              initialValue: model.initFixedFormValue(),
                              child: Column(
                                children: [
                                  _formFeeField(
                                    key: _rentFieldKey,
                                    name: 'rent',
                                    title: '每月租金',
                                    unit: "元/月",
                                    isLarge: true,
                                  ),
                                  SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _formFeeField(
                                          key: _electFieldKey,
                                          name: 'elect',
                                          title: '电费单价',
                                          unit: "元/度",
                                        ),
                                      ),
                                      SizedBox(width: 24),
                                      Expanded(
                                        child: _formFeeField(
                                          key: _waterFieldKey,
                                          name: 'water',
                                          title: '水费单价',
                                          unit: "元/度",
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(height: 16),

                        // 额外收费项 Section
                        _optFeeBlock(ctx, model),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.all(16).copyWith(
                bottom: 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    var keys = [_formMeteringKey,_formFixedKey,_formAddonsKey];
                    Map<String, dynamic> data = {};
                    {
                      bool validate = true;
                      for (final formKey in keys) {
                        validate &= formKey.currentState?.saveAndValidate()??false;
                        debugPrint(formKey.currentState?.value.toString());
                      }
                      if(!validate){
                        return;
                      }
                    }
                    {
                      for (final formKey in keys) {
                        var val = formKey.currentState?.value;
                        if (val == null) {
                          return;
                        }
                        data.addAll(val);
                      }
                    }

                    await model.submit(data);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    elevation: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "提交",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
