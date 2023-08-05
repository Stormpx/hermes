import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

abstract class HermesState<T extends StatefulWidget> extends State<T>{


  @override
  void initState() {
    ToastContext().init(context);
  }
}