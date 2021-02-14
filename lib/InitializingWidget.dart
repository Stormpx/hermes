import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';


typedef WidgetBuilder = Widget Function();


class InitializingWidget extends StatelessWidget {
  bool initialized;
  WidgetBuilder builder;
  Text loadingText;

  InitializingWidget(
      {@required this.builder,
      this.initialized = true,this.loadingText})
      : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return Container(
          height: double.maxFinite,
          width: double.maxFinite,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              loadingText??Text("加载中"),
              AnimatedRotationBox(
                child: GradientCircularProgressIndicator(
                  radius: 100.0,
                  colors: [
                    Colors.redAccent,
                    Colors.lightBlue,
                    Colors.greenAccent
                  ],
                  value: .8,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ],
          ));
    } else {
      return builder();
    }
  }
}
