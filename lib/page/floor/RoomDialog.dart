import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RoomDialog extends StatefulWidget {
  final String? title;
  final String? floorName;
  final Map<String, dynamic>? initValue;
  final void Function(Map<String, dynamic>) onSubmit;

  const RoomDialog({
    Key? key,
    this.title,
    this.floorName,
    this.initValue,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<RoomDialog> createState() => _RoomDialogState();
}

class _RoomDialogState extends State<RoomDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _nameFieldKey = GlobalKey<FormBuilderFieldState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 12,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                widget.title ?? "输入套间名称",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                  color: Color(0xFF002D1C),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "请输入套间名称",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF414844),
                ),
              ),
              SizedBox(height: 32),

              // Input Fields
              FormBuilder(
                key: _formKey,
                initialValue: widget.initValue ?? {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Floor Name (Read-only)
                    if (widget.floorName != null) ...[
                      Text(
                        "所属楼层",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Color(0xFF414844),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Color(0xFFF3F4F1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Color(0xFFC1C8C2).withOpacity(0.2),
                            width: 0,
                          ),
                        ),
                        child: Text(
                          widget.floorName!,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFF414844),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],

                    // Room Name
                    Text(
                      "套间名称",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Color(0xFF414844),
                      ),
                    ),
                    SizedBox(height: 8),
                    FormBuilderTextField(
                      key: _nameFieldKey,
                      name: "name",
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: "名称必填"),
                      ]),
                      autofocus: true,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "例如：101室",
                        hintStyle: TextStyle(
                          color: Color(0xFF717973),
                          fontSize: 18.0,
                        ),
                        filled: true,
                        fillColor: Color(0xFFE2E3E0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Color(0xFFC1C8C2).withOpacity(0.2),
                            width: 0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Color(0xFFC1C8C2).withOpacity(0.2),
                            width: 0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Color(0xFFC1C8C2).withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFF414844)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "取消",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF414844),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF002D1C),
                            Color(0xFF00452E),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF002D1C).withOpacity(0.1),
                            offset: Offset(0, 4),
                            blurRadius: 6,
                            spreadRadius: -4,
                          ),
                          BoxShadow(
                            color: Color(0xFF002D1C).withOpacity(0.1),
                            offset: Offset(0, 10),
                            blurRadius: 15,
                            spreadRadius: -3,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () async {
                          var validate = _formKey.currentState?.saveAndValidate();
                          if (!(validate ?? false)) {
                            return;
                          }
                          var val = _formKey.currentState?.value;
                          if (val == null) {
                            return;
                          }
                          widget.onSubmit(val);
                        },
                        child: Text(
                          "确认",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}