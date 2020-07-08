import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../globals.dart';
import './styles.dart';
import '../../theme.dart';

class LoadingScreen extends StatelessWidget {
  final Globals _globals = Globals();
  String title;
  String text;
  String size;
  dynamic customIcon;
  dynamic _icon;
  bool showIcon;
  bool showSuccessIcon;

  LoadingScreen({
    Key key,
    this.title = '',
    this.text = '',
    this.size = Constants.MEDIUM,
    this.customIcon,
    this.showIcon = true,
    this.showSuccessIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);
    double iconSize;

    if (size == Constants.SMALL) {
      iconSize = 25.0;
    } else if (size == Constants.MEDIUM) {
      iconSize = 50.0;
    } else if (size == Constants.LARGE) {
      iconSize = 100.0;
    }

    if (showSuccessIcon) {
      _icon = SpinKitFoldingCube(color: theme.secondary, size: iconSize);
    } else {
      _icon = customIcon ??
          SpinKitFoldingCube(color: theme.secondary, size: iconSize);
    }

    return Container(
      key: _globals.scaffoldKey,
      height: screenSize.height,
      width: screenSize.width,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Visibility(
            visible: title.trim().isNotEmpty,
            child: Column(
              children: <Widget>[
                Container(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: Styles.title['fontSize'],
                      color: theme.secondary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
          Visibility(
              visible: text.trim().isNotEmpty,
              child: Column(
                children: <Widget>[
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: Styles.text['fontSize'],
                      color: theme.secondary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              )),
          Visibility(
            visible: showIcon,
            child: _icon,
          ),
        ],
      ),
    );
  }

  // LoadingScreen({
  //   Key key,
  //   String title,
  //   String text,
  //   dynamic icon,
  //   bool showIcon,
  // }) : super(key: key);

  // @override
  // _LoadingState createState() => _LoadingState();
}

// class _LoadingState extends State<LoadingScreen> {

// }
