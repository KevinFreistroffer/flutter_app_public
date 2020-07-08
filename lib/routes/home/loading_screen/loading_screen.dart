import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../constants.dart';
import '../../../globals.dart';
import './styles.dart';

class LoadingScreen extends StatelessWidget {
  final Globals _globals = Globals();
  String title;
  String text;
  dynamic icon;
  bool showIcon;
  bool showSuccessIcon;

  LoadingScreen({
    this.title = '',
    this.text = '',
    this.showIcon = true,
    this.showSuccessIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // icon = Loading(
    //   indicator: BallPulseIndicator(),
    //   size: Styles.icon['size'],
    //   color: Theme.of(context).primaryColor,
    // );

    if (showSuccessIcon == false) {
      icon = SpinKitFoldingCube(
        color: Theme.of(context).primaryColor,
        size: 100.0,
      );
    } else {
      icon = Icon(
        Icons.check,
        color: Theme.of(context).primaryColor,
        size: 100,
      );
    }

    return Container(
      key: _globals.scaffoldKey,
      height: size.height,
      width: size.width,
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
                      color: Theme.of(context).primaryColor,
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
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              )),
          Visibility(
            visible: showIcon,
            child: icon,
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
