import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';
import '../../globals.dart';
import './styles.dart';
import '../../theme.dart';

class LoadingScreen extends StatefulWidget {
  final String title;
  final String text;
  final String size;
  final dynamic customIcon;
  final bool showIcon;
  final bool showSuccessIcon;

  dynamic _icon;

  LoadingScreen({
    Key key,
    this.title = '',
    this.text = '',
    this.size = Constants.MEDIUM,
    this.customIcon,
    this.showIcon,
    this.showSuccessIcon,
  }) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final Globals _globals = Globals();
  var _icon;
  bool increment = true;
  bool decrement = false;

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);
    double iconSize;

    if (widget.size == Constants.SMALL) {
      iconSize = 25.0;
    } else if (widget.size == Constants.MEDIUM) {
      iconSize = 50.0;
    } else if (widget.size == Constants.LARGE) {
      iconSize = 100.0;
    }

    if (widget.showSuccessIcon != null && widget.showSuccessIcon == true) {
      _icon = SpinKitFoldingCube(color: theme.onBackground, size: iconSize);
    } else {
      _icon = widget.customIcon ??
          SpinKitFoldingCube(color: theme.onBackground, size: iconSize);
    }

    return Container(
      padding: EdgeInsets.only(
          left: mediaSize.width * .1, right: mediaSize.width * .1),
      key: _globals.scaffoldKey,
      height: mediaSize.height,
      width: mediaSize.width,
      color: theme.primary,
      child: Stack(
        children: <Widget>[
          Container(
            height: mediaSize.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(visible: widget.showIcon, child: _icon)
              ],
            ),
          ),
          Container(
            height: mediaSize.height - mediaSize.height * .1,
            width: mediaSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  visible: widget.text.trim().isNotEmpty,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.text.toUpperCase(),
                        style: TextStyle(
                          fontSize: Styles.text['fontSize'],
                          letterSpacing: 5.0,
                          fontWeight: FontWeight.w100,
                          color: theme.onBackground,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
