import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../services/position_service.dart';
import '../../../services/raspberrypi_service.dart';
import '../../../services/times_service.dart';
import '../../../constants.dart';
import '../../../theme.dart';
import '../../../globals.dart';

class Connection extends StatelessWidget {
  final Globals _globals = Globals();
  final TabController controller;
  final Function connect;
  final Function disconnect;
  final Function executeShellCommand;
  final Function exitScript;
  final String status;
  final dynamic error;
  Connection({
    Key key,
    this.connect,
    this.disconnect,
    this.executeShellCommand,
    this.exitScript,
    this.controller,
    this.status,
    this.error,
  }) : super(key: key);

  // Future<void> _connect() async {
  //   var connectionResponse = await _raspberryPiService.connectToClient();
  //   print('connection.dart _connect() connectionResponse: $connectionResponse');

  //   if (connectionResponse == Constants.SSH_CONNECT_SUCCESS) {
  //     // success
  //     print('successfully connected to the RaspberryPi');
  //   } else {
  //     print('displayErrorDialog $connectionResponse');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of(context, listen: false);
    final Size size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 32),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10000),
                boxShadow: [
                  BoxShadow(
                    color: status == Constants.DISCONNECTED
                        ? Colors.red
                        : status == Constants.CONNECTING
                            ? Colors.green
                            : theme.secondary,
                    blurRadius: 10,
                    spreadRadius: 10,
                  )
                ],
              ),
              child: RaisedButton(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1000),
                ),
                child: Icon(
                  MaterialCommunityIcons.power,
                  color: status == Constants.DISCONNECTED
                      ? Colors.red
                      : status == Constants.CONNECTING
                          ? Colors.green
                          : theme.secondary,
                  size: 32,
                ),
                onPressed: () {
                  if (status == Constants.CONNECTING) {
                    return null;
                  } else if (status == Constants.DISCONNECTED) {
                    connect();
                  } else {
                    disconnect();
                  }
                },
              ),
            ),
            SizedBox(height: 32),
            RaisedButton(
              child: Text('Start python script'),
              onPressed: () {
                executeShellCommand();
              },
            ),
            SizedBox(height: 32),
            RaisedButton(
              child: Text('Exit'),
              onPressed: () {
                exitScript();
              },
            ),
          ],
        ),
        SizedBox(height: 32),
        Container(
          width: size.width,
          height: size.height * .1,
          // color: theme.secondary,
          constraints: BoxConstraints(
            minHeight: 30,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (status == Constants.CONNECTING) ...[
                SpinKitRipple(color: theme.onBackground, size: 48.0),
              ],
              if (status != Constants.CONNECTING) ...[
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    //fontSize: Styles.text['fontSize'],
                    letterSpacing: 5.0,
                    fontWeight: FontWeight.w100,
                    color: theme.onBackground.withOpacity(0.5),
                    decoration: TextDecoration.none,
                  ),
                ),
              ]
            ],
          ),
        )
      ],
    );
    // return Stack(
    //   //alignment: Alignment.center,
    //   children: <Widget>[
    //     Positioned(
    //       // width: size.width,
    //       // height: size.height - Constants.APP_BAR_HEIGHT,
    //       // top: 0,
    //       child: Container(
    //         color: Colors.blue,
    //         //margin: EdgeInsets.only(top: Constants.APP_BAR_HEIGHT),
    //         //color: Colors.red,
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: <Widget>[
    //             Container(
    //               width: 150,
    //               height: 150,
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(10000),
    //                 boxShadow: [
    //                   BoxShadow(
    //                       color: Colors.pink, blurRadius: 10, spreadRadius: 10)
    //                 ],
    //               ),
    //               child: RaisedButton(
    //                 color: Colors.black,
    //                 shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(1000),
    //                 ),
    //                 child: Text('Connect',
    //                     style: TextStyle(
    //                       color: Colors.white,
    //                     )),
    //                 onPressed: () => connect(),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //     Positioned(
    //       bottom: size.height * .1,
    //       child: Align(
    //         alignment: Alignment.center,
    //         child: Container(
    //           padding: EdgeInsets.only(top: 20),
    //           decoration: BoxDecoration(
    //               color: theme.background.withOpacity(0.8),
    //               boxShadow: [
    //                 BoxShadow(
    //                   color: theme.background.withOpacity(0.5),
    //                   blurRadius: 3,
    //                   spreadRadius: 3,
    //                   offset: Offset(0, -1),
    //                 ),
    //               ]),
    //           //height: size.height - size.height * .2,
    //           width: size.width,
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.end,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: <Widget>[
    //               Text(
    //                 'Disconnected'.toUpperCase(),
    //                 style: TextStyle(
    //                   //fontSize: Styles.text['fontSize'],
    //                   letterSpacing: 5.0,
    //                   fontWeight: FontWeight.w100,
    //                   color: theme.onBackground,
    //                   decoration: TextDecoration.none,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );

    // return Center(
    //   child: Container(
    //     height: size.height - (Constants.APP_BAR_HEIGHT * 2),
    //     padding: EdgeInsets.all(size.height * .02),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: <Widget>[
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: <Widget>[
    //             Container(
    //               width: 150,
    //               height: 150,
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(10000),
    //                 boxShadow: [
    //                   BoxShadow(
    //                       color: Colors.pink, blurRadius: 10, spreadRadius: 10)
    //                 ],
    //               ),
    //               child: RaisedButton(
    //                 color: Colors.black,
    //                 shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(1000),
    //                 ),
    //                 child: Text('Connect',
    //                     style: TextStyle(
    //                       color: Colors.white,
    //                     )),
    //                 onPressed: () => connect(),
    //               ),
    //             ),
    //           ],
    //         ),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: <Widget>[
    //             Text(
    //               'Disconnected',
    //               style: TextStyle(
    //                 letterSpacing: 5.0,
    //                 fontWeight: FontWeight.w100,
    //                 color: theme.onBackground,
    //                 decoration: TextDecoration.none,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
