import 'package:flutter/material.dart';
import 'package:hermes/App.dart';
import 'package:hermes/component/InitializingPage.dart';
import 'package:hermes/component/InitializingWidget.dart';
import 'package:hermes/page/Rebuild.dart';
import 'package:provider/provider.dart';

class RebuildPage extends StatelessWidget {
  final Widget page;

  RebuildPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (ctx) => RebuildModel().init(),
      initialData: null,
      child: Consumer<RebuildModel?>(
        builder: (ctx,model,child){
          return InitializingPage(
            initialized: model!=null,
            title: Text(""),
            child: page,
          );
        },
      ),
    );
  }
}
