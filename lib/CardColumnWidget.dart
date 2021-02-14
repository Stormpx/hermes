
 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardColumnWidget extends StatelessWidget {


  Color color;
  Widget child;

  CardColumnWidget( {@required this.child,this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 0,
      borderOnForeground: false,

      //设置shape，这里设置成了R角
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0)),
      ),
      //对Widget截取的行为，比如这里 Clip.antiAlias 指抗锯齿
      clipBehavior: Clip.antiAlias,
//      semanticContainer: false,
      child: child,
    );
  }



}

