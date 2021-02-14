import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
///
class FullCoverOpaque extends StatelessWidget {
  FullCoverOpaque({
    Key key,
    this.child,
    this.color= Colors.grey,
    this.opacity=0.8
  }):super(key:key);

  Widget child;
  Color color;
  double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        color: color,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
