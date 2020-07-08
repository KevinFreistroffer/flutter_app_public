// child: Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: <Widget>[
//                                 // SizedBox(
//                                 //   height: size.height *
//                                 //       (orientation == Orientation.landscape
//                                 //           ? 0.0625
//                                 //           : 0.125),
//                                 // ),
//                                 Container(
//                                   padding: EdgeInsets.all(20),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: <Widget>[
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         children: <Widget>[
//                                           Expanded(
//                                             child: Text(
//                                               'Status: $_status',
//                                               style: TextStyle(
//                                                   fontSize: size.width * .05,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                   decoration:
//                                                       TextDecoration.none),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(
//                                         height: size.height * .025,
//                                       ),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         children: <Widget>[
//                                           Text(
//                                             'Location: ',
//                                             style: TextStyle(
//                                                 fontSize: size.width * .05,
//                                                 fontWeight: FontWeight.bold,
//                                                 decoration:
//                                                     TextDecoration.none),
//                                           ),
//                                         ],
//                                       ),
//                                       Visibility(
//                                         visible: _currentPosition != null,
//                                         child: Column(
//                                           children: <Widget>[
//                                             Row(
//                                               children: <Widget>[
//                                                 Expanded(
//                                                   child: Text(
//                                                     'Lat: ${_currentPosition?.latitude}',
//                                                     style: TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize:
//                                                           size.width * .05,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             Row(
//                                               children: <Widget>[
//                                                 Expanded(
//                                                   child: Text(
//                                                     'Long: ${_currentPosition?.longitude}',
//                                                     style: TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize:
//                                                           size.width * .05,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(height: size.height * .1),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: <Widget>[
//                                     Container(
//                                       width: 200,
//                                       child: RaisedButton.icon(
//                                         color: _status == Constants.CONNECTED
//                                             ? Colors.black
//                                             : theme.secondary,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.all(
//                                               Radius.circular(1000)),
//                                         ),
//                                         icon: Icon(
//                                           Icons.settings_remote,
//                                           color: _status == Constants.CONNECTED
//                                               ? Colors.white
//                                               : theme.onSecondary,
//                                         ),
//                                         padding: EdgeInsets.all(15),
//                                         label: Text(
//                                           '${_status == Constants.DISCONNECTED ? Constants.CONNECT : Constants.DISCONNECT}',
//                                           style: TextStyle(
//                                               color:
//                                                   _status == Constants.CONNECTED
//                                                       ? Colors.white
//                                                       : theme.onSecondary),
//                                         ),
//                                         onPressed: () async {
//                                           _status == Constants.DISCONNECTED
//                                               ? await _sshToRaspberryPi()
//                                               : await _disconnectClient();
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: size.height * .05),
//                                 Visibility(
//                                   visible: _status == Constants.CONNECTED,
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: <Widget>[
//                                       Container(
//                                         width: 200,
//                                         child: Theme(
//                                           data: theme.themeData,
//                                           child: RaisedButton.icon(
//                                             icon: Icon(
//                                               Icons.location_searching,
//                                               color: _gettingLocation
//                                                   ? Colors.transparent
//                                                   : theme.onSecondary,
//                                             ),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.all(
//                                                 Radius.circular(1000),
//                                               ),
//                                             ),
//                                             padding: EdgeInsets.all(15),
//                                             label: Text(
//                                               '${_gettingLocation ? 'Loading ...' : 'Get Location'}',
//                                               style: TextStyle(
//                                                 color: theme.background
//                                                     .withOpacity(0.65),
//                                               ),
//                                             ),
//                                             onPressed: () async {
//                                               // GET LOCATION METHOD
//                                               await _getCurrentLocation();
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(height: size.height * .05),

//                                 Visibility(
//                                   visible: _currentPosition != null,
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: <Widget>[
//                                       Container(
//                                         width: 200,
//                                         child: Theme(
//                                           data: theme.themeData,
//                                           child: RaisedButton.icon(
//                                               icon: Icon(
//                                                   Icons.location_searching),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.all(
//                                                   Radius.circular(1000),
//                                                 ),
//                                               ),
//                                               padding: EdgeInsets.all(15),
//                                               label: Text(
//                                                 'START',
//                                                 style: TextStyle(
//                                                   color: theme.background
//                                                       .withOpacity(0.65),
//                                                 ),
//                                               ),
//                                               onPressed: () async {
//                                                 // GET LOCATION METHOD
//                                                 await run();
//                                               }),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
