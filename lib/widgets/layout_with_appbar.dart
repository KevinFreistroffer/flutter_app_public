import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../theme.dart';

class LayoutWithAppBar extends StatelessWidget {
  LayoutWithAppBar({
    Key key,
    this.appBar,
    this.minHeight,
    this.heightOffset = 0.0,
    this.child,
  }) : super(key: key);

  final dynamic appBar;
  final double minHeight;
  final double heightOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);

    return Scaffold(
      appBar: appBar,
      body: Center(
        child: Container(
          height: size.height,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
