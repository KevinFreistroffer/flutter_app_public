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
  final String sshStatus;
  final String locationStatus;
  final dynamic error;
  Connection({
    Key key,
    this.connect,
    this.disconnect,
    this.executeShellCommand,
    this.exitScript,
    this.controller,
    this.sshStatus,
    this.locationStatus,
    this.error,
  }) : super(key: key);

  // Future<void> _connect() async {
  //   var connectionResponse = await _RPiService.connectToClient();
  //   print('connection.dart _connect() connectionResponse: $connectionResponse');

  //   if (connectionResponse == Constants.SSH_CONNECT_SUCCESS) {
  //     // success
  //     print('successfully connected to the RaspberryPi');
  //   } else {
  //     print('displayErrorDialog $connectionResponse');
  //   }
  // }

  TextStyle _outputConnectionTextStyle(AppTheme theme) {
    return TextStyle(
      //fontSize: Styles.text['fontSize'],
      letterSpacing: 5.0,
      fontWeight: FontWeight.w100,
      color: theme.onBackground.withOpacity(0.5),
      decoration: TextDecoration.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of(context, listen: false);
    final Size size = MediaQuery.of(context).size;
    bool switchValueIsActive = sshStatus == Constants.SSH_DISCONNECTED ||
            sshStatus == Constants.SSH_CONNECTING
        ? false
        : true;

    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: size.width,
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          color: Color.fromRGBO(232, 234, 237, 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(sshStatus.toUpperCase()),
              Switch(
                value: switchValueIsActive,
                onChanged: (bool value) {
                  !switchValueIsActive ? connect() : disconnect();
                },
                activeTrackColor: Colors.blue,
                activeColor: Colors.white,
              ),
            ],
          ),
        ),
        Visibility(
          visible: !switchValueIsActive,
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Connect in the upper right hand corner',
                    style: TextStyle(
                        fontSize: 24, color: Colors.black.withOpacity(0.5)))
              ],
            ),
          ),
        ),
        SizedBox(height: 32),
        Container(
          width: size.width,
          height: size.height * .1,
          // color: theme.secondary,
          constraints: BoxConstraints(
            minHeight: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(sshStatus.toUpperCase(),
                      style: _outputConnectionTextStyle(theme)),
                  SizedBox(width: 16),
                  if (sshStatus == Constants.SSH_CONNECTED) ...[
                    Icon(Icons.check,
                        color: theme.onBackground.withOpacity(0.5)),
                  ],
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    locationStatus.toUpperCase(),
                    style: _outputConnectionTextStyle(theme),
                  )
                ],
              )
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
