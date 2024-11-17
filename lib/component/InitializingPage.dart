import 'package:flutter/material.dart';


typedef WidgetBuilder = Widget Function();


class InitializingPage extends StatelessWidget {
  bool initialized;
  Widget? child;
  WidgetBuilder? builder;
  Text title;
  Text? loadingText;

  InitializingPage(
      {required this.title,this.child, this.builder,
        this.initialized = true,this.loadingText}){
    assert (child!=null || builder!=null);
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return Scaffold(
        appBar: AppBar(
          title: title,
        ),
        body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            color: Colors.white,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                loadingText??Text("加载中"),
                // AnimatedRotationBox(
                //   child: GradientCircularProgressIndicator(
                //     radius: 100.0,
                //     colors: [
                //       Colors.redAccent,
                //       Colors.lightBlue,
                //       Colors.greenAccent
                //     ],
                //     value: .8,
                //     backgroundColor: Colors.transparent,
                //   ),
                // ),
              ],
            ))
      );
    } else {
      if(child!=null){
        return child!;
      }
      return builder!();
    }
  }
}
