import 'package:flutter/material.dart';

class LevitationContainer extends StatelessWidget {
  EdgeInsetsGeometry? padding;
  Color? shadowColor;
  Widget child;

  LevitationContainer({required this.child, EdgeInsetsGeometry? padding, Color? shadowColor})
      : this.padding = padding!=null?padding:EdgeInsets.only(top: 10),
        this.shadowColor = shadowColor!=null?shadowColor:Colors.grey.withOpacity(0.5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Card(
        elevation: 8,
        shadowColor: shadowColor,
        child: Container(child: child),
      ),
    );
  }
}
