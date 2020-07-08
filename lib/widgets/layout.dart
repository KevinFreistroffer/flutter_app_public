import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../theme.dart';

class Layout extends StatelessWidget {
  Layout({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        size.width * .1,
        size.width * .125,
        size.width * .1,
        size.width * .125,
      ),
      color: theme.background,
      height: size.height,
      child: Center(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return SingleChildScrollView(
              child: child,
            );
          },
        ),
      ),
    );
  }
}
