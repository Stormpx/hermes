 import 'package:flutter/material.dart';

class FloatButton extends StatelessWidget {

  VoidCallback onPressed;

  Icon icon;

  FloatButton({this.onPressed,this.icon})
  ;

  @override
   Widget build(BuildContext context) {
     return Container(
       width: 60,
       height: 60,
       decoration: BoxDecoration(
           color: Colors.lightBlueAccent, shape: BoxShape.circle),
       child: IconButton(
           icon: icon??Icon(
             Icons.add,
             color: Colors.white,
             size: 30,
           ),
           onPressed: onPressed),
     );
   }
 }
