import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ssh/ssh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_suncalc/flutter_suncalc.dart';

import '../../services/loading.service.dart';
import '../../globals.dart';
import '../../services/storage.service.dart';
import '../../constants.dart';
import '../../services/authentication.service.dart';
import '../../services/database.service.dart';
import '../../services/raspberrypi_service.dart';
import '../../services/solar_service.dart';
import '../../services/position_service.dart';
import '../../services/times_service.dart';
import '../../widgets/AppBars/signed_in_app_bar.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';
import '../../error_dialog.dart';
import '../../error_dialog.dart';
import './styles.dart';
import '../../theme.dart';
import '../../wait.dart';
import '../../state/user_model.dart';
import '../../state/coordinates_model.dart';
import '../../state/times_model.dart';
import '../../__private_config__.dart';

class BottomLayer extends CustomPainter {
  final BuildContext context;
  final Orientation orientation;
  AppTheme theme;
  Size mqSize;
  BottomLayer(this.context, this.orientation) {
    theme = Provider.of(context);
  }
  @override
  void paint(Canvas canvas, Size size) {
    mqSize = MediaQuery.of(context).size;
    // if orientation is landscape than mqSize.width * .4, height
    double width = orientation == Orientation.portrait
        ? mqSize.width * .7
        : mqSize.width * .5;
    double height = orientation == Orientation.portrait ? 250 : 300;
    final rect = Offset(-width / 2, 0) & Size(width, height);
    final startAngle = math.pi;
    final sweepAngle = math.pi;
    final useCenter = false;
    final paint = Paint()
      ..color = theme.secondary.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class TopLayer extends CustomPainter {
  final BuildContext context;
  final Orientation orientation;
  AppTheme theme;
  Size mqSize;
  TopLayer(this.context, this.orientation) {
    theme = Provider.of(context);
  }
  @override
  void paint(Canvas canvas, Size size) {
    mqSize = MediaQuery.of(context).size;
    // if orientation is landscape than mqSize.width * .4, height
    double width = orientation == Orientation.portrait
        ? mqSize.width * .7
        : mqSize.width * .5;
    double height = orientation == Orientation.portrait ? 250 : 300;
    final rect = Offset(-width / 2, 0) & Size(width, height);
    final startAngle = math.pi;
    final sweepAngle = math.pi * .2;
    final useCenter = false;
    final paint = Paint()
      ..color = theme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  // with SingleTickerProviderStateMixin {
  final Globals _globals = Globals();
  final AuthenticationService _authService = AuthenticationService();
  final LoadingService _loadingService = LoadingService();
  final RaspberryPiService _raspberryPiService = RaspberryPiService();
  final SolarService _solarService = SolarService();
  final PositionService _positionService = PositionService();
  final CoordinatesModel _coordinatesModel = CoordinatesModel();
  final TimesService _timesService = TimesService();

  TimesModel _timesModel;
  PageController _pageController;
  Position _currentPosition;
  String _username = '';
  String _pythonResponse = '';
  String _location = Constants.LOCATION_NOT_AVAILABLE;
  String _status = Constants.DISCONNECTED;
  String _locationStatus = Constants.LOCATION_NOT_AVAILABLE;
  String _connectButtonText = Constants.CONNECT;
  double _latitude;
  double _longitude;

  int _currentPage = 0;
  bool displayDashboardContent = false;

  AppTheme theme;

  final client = SSHClient(
    host: '1.1.1.1',
    port: 22,
    username: 'abcdefg',
    passwordOrKey: Config.password,
  );

  @override
  void initState() {
    super.initState();

    _positionService.getCurrentPosition().then((Position position) async {
      print('getCurrentPosition position $position');
      _coordinatesModel.set(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // setState(() {
      //   _latitude = position.latitude;
      //   _longitude = position.longitude;
      // });

      final timesResponse =
          await _timesService.getSunriseAndSunset(_latitude, _longitude);
      if (timesResponse.success) {
        _timesModel.set(
          sunrise: timesResponse.data.sunrise,
          sunset: timesResponse.data.sunset,
          dayLength: timesResponse.data.dayLength,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Provider.of(context);
  }

  _setConnectedState(state) {
    if (state == Constants.CONNECTING) {
      setState(() => _status = Constants.CONNECTING);
    }

    switch (state) {
      case Constants.CONNECTING:
        setState(() {
          _status = Constants.CONNECTING;
          _connectButtonText = Constants.CONNECTING;
        });
        break;
      case Constants.CONNECTED:
        setState(() {
          _status = Constants.CONNECTED;
          _connectButtonText = Constants.DISCONNECT;
        });
        break;
      case Constants.DISCONNECTED:
        setState(() {
          _status = Constants.DISCONNECTED;
          _connectButtonText = Constants.CONNECT;
        });
        break;
    }
  }

  Future<void> _sshToRaspberryPi() async {
    setState(() {
      _status = Constants.CONNECTING;
    });

    try {
      final result = await _raspberryPiService
          .connectToClient()
          .timeout(Duration(seconds: 3), onTimeout: () async {
        print('Could not connect to client after 3 seconds timeout.');
        // "Could not connect to the server.
        // Try turning off and turning on the Raspberry Pi or the Wifi Network."
        _setConnectedState(Constants.DISCONNECTED);
        _displayErrorDialog(
          'Could not connect to the server \n Try turning off the Raspberry Pi, then turning it back on, or reset your network connection.',
          barrierDismissible: true,
        );
        return;
      });
      if (result == "session_connected") {
        _setConnectedState(Constants.CONNECTED);
      } else {}
    } catch (error) {
      print('An error occurred connecting to the client $error');
      // displayErrorDialog();
      _setConnectedState(Constants.DISCONNECTED);
    }
  }

  _disconnectClient() {
    _raspberryPiService.disconnectClient();
    _setConnectedState(Constants.DISCONNECTED);
  }

  // Future<void> _getCurrentLocation() async {
  //   setState(() => _gettingLocation = true);

  //   try {
  //     final Position position = await getCurrentLocation();
  //     setState(() {
  //       _currentPosition = position;
  //       _latitude = position.latitude;
  //       _longitude = position.longitude;
  //     });
  //   } catch (error) {
  //     print('An error occurred in getCurrentPosition() $error');
  //   }

  //   setState(() => _gettingLocation = false);
  // }

  Future<void> _executePythonScript() async {
    try {
      final success = await client.execute('python python2.py');
      print(success.toUpperCase());

      setState(() => _pythonResponse = success);
    } catch (error) {
      print(error.toString().toUpperCase());
      setState(() => _pythonResponse = error.toString());
    }
  }

  _displayErrorDialog(
    String error, {
    bool barrierDismissible = true,
  }) {
    final styles = ErrorDialogStyles.alertDialog;
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible, // user must tap button!
      builder: (BuildContext context) {
        final Size size = MediaQuery.of(context).size;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Colors.red[300],
            ),
            padding: EdgeInsets.fromLTRB(
              size.width * .1,
              size.width * .125,
              size.width * .1,
              size.width * .125,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.error,
                  size: 70,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          titlePadding: styles['titlePadding'],
          buttonPadding: styles['buttonPadding'],
          contentPadding: styles['contentPadding'],
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.4,
                    fontWeight: FontWeight.w100,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              child: Text(
                'DISMISS',
                style: TextStyle(
                  fontSize: styles['actions']['flatButton']['text']['fontSize'],
                  fontWeight: styles['actions']['flatButton']['text']
                      ['fontWeight'],
                  color: Colors.black45,
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    print('size.width * .5 ${size.width * .5}');

    //final AppTheme theme = Provider.of<AppTheme>(context);

    return Consumer3<UserModel, CoordinatesModel, TimesModel>(
      builder: (context, user, coordinates, times, child) {
        String displayName = user.platform == Constants.EMAIL_OR_USERNAME
            ? user.username
            : user.nickname;

        print(
            'Consumer coordinates $coordinates ${coordinates.latitude} ${coordinates.longitude}');
        print(
            'times.sunrise times.sunset times.dayLength ${times.sunrise} ${times.sunset} ${times.dayLength}');
        String latitude = coordinates.latitude != null
            ? coordinates.latitude.toStringAsFixed(3)
            : 'N/A';
        String longitude = coordinates.longitude != null
            ? coordinates.longitude.toStringAsFixed(3)
            : 'N/A';

        final String username = displayName.length >
                Constants.MAX_USERNAME_DISPLAY_LENGTH
            ? '${displayName.substring(0, Constants.MAX_USERNAME_DISPLAY_LENGTH)}...'
            : displayName;
        return StreamBuilder(
          initialData: {
            'isOpen': true,
            'isSigningOut': false,
            'title': '',
            'text': '',
            'size': 'medium',
            'showIcon': true,
            'showSuccessIcon': false,
          },
          stream: _loadingService.controller.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Consumer<UserModel>(builder: (context, user, child) {
              print('Dashboard Consumer user $user ${user.platform}');
              String displayName = user.platform == Constants.EMAIL_OR_USERNAME
                  ? user.username
                  : user.nickname;

              final String username = displayName.length >
                      Constants.MAX_USERNAME_DISPLAY_LENGTH
                  ? '${displayName.substring(0, Constants.MAX_USERNAME_DISPLAY_LENGTH)}...'
                  : displayName;

              Widget _widget;
              if (snapshot.hasData) {
                if (snapshot.data['isOpen']) {
                  _loadingService.add(isOpen: false);

                  _widget = LoadingScreen(
                    customIcon: SpinKitRing(
                      color: theme.secondary,
                      size: 25.0,
                    ),
                  );
                } else {
                  _widget = Scaffold(
                    key: _globals.scaffoldKey,
                    appBar: _currentPage == 0
                        ? PreferredSize(
                            preferredSize:
                                Size.fromHeight(Constants.APP_BAR_HEIGHT),
                            child: SignedInAppBar(
                              title: 'SunScript',
                              automaticallyImplyLeading: false,
                              backgroundColor: theme.secondary,
                              elevation: 5.0,
                              height: 200,
                            ),
                          )
                        : null,
                    body: Container(
                      height: size.height,
                      width: size.width,
                      //color: Color.fromRGBO(39, 16, 38, 1),
                      //color: Color.fromRGBO(30, 30, 30, 1),
                      color: Color.fromRGBO(63, 70, 85, 1),
                      child: OrientationBuilder(
                        builder: (
                          BuildContext context,
                          Orientation orientation,
                        ) {
                          return SingleChildScrollView(
                            child: Container(
                              color: Color.fromRGBO(65, 72, 88, 1),
                              padding: EdgeInsets.only(
                                top: size.width * 0.025,
                                bottom: size.width * .05,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          _status,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.25),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    duration: Duration(milliseconds: 215),
                                    opacity:
                                        _status == Constants.DISCONNECTED ||
                                                _status == Constants.CONNECTING
                                            ? 0.5
                                            : 1,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          height: orientation ==
                                                  Orientation.portrait
                                              ? 125
                                              : 150,
                                          width: size.width,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Container(
                                                width: size.width,
                                                height: size.width * .75,
                                                child: Stack(
                                                  overflow: Overflow.visible,
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    Positioned(
                                                      top: 0,
                                                      child: CustomPaint(
                                                        painter: BottomLayer(
                                                          context,
                                                          orientation,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      child: CustomPaint(
                                                        painter: TopLayer(
                                                          context,
                                                          orientation,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: -size.width * .1,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                          bottom: orientation ==
                                                                  Orientation
                                                                      .landscape
                                                              ? 95
                                                              : 50,
                                                        ),
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text(
                                                              '20°',
                                                              /**
                                                               * And this is the degree or the pan angle. at sunrise on the summer
                                                               * // soltice, the angle is either -90, 0, or 180.
                                                               * 0 
                                                               */
                                                              style: TextStyle(
                                                                fontSize: 50,
                                                                color: theme
                                                                    .onBackground
                                                                    .withOpacity(
                                                                        0.65),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: orientation ==
                                                              Orientation
                                                                  .landscape
                                                          ? -15.25
                                                          : -35.25,
                                                      child: Container(
                                                        width: 150,
                                                        //color: Colors.red,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment: _latitude == null &&
                                                                      _longitude ==
                                                                          null
                                                                  ? MainAxisAlignment
                                                                      .center
                                                                  : MainAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  width: _latitude ==
                                                                              null &&
                                                                          _longitude ==
                                                                              null
                                                                      ? null
                                                                      : 80,
                                                                  child: Text(
                                                                    'Latitude',
                                                                    style: TextStyle(
                                                                        color: theme
                                                                            .onBackground
                                                                            .withOpacity(0.5)),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  latitude,
                                                                  style:
                                                                      TextStyle(
                                                                    color: theme
                                                                        .onBackground
                                                                        .withOpacity(
                                                                            0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  width: _latitude ==
                                                                              null &&
                                                                          _longitude ==
                                                                              null
                                                                      ? null
                                                                      : 80,
                                                                  child: Text(
                                                                    'Longitude: ',
                                                                    style: TextStyle(
                                                                        color: theme
                                                                            .onBackground
                                                                            .withOpacity(0.5)),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  longitude,
                                                                  style:
                                                                      TextStyle(
                                                                    color: theme
                                                                        .onBackground
                                                                        .withOpacity(
                                                                            0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 9.75),
                                        Container(
                                          width: orientation ==
                                                  Orientation.portrait
                                              ? size.width * .84
                                              : size.width * .6,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  Icon(
                                                    Feather.sunrise,
                                                    size: 30,
                                                    color: theme.secondary,
                                                  ),
                                                  SizedBox(height: 9.75),
                                                  Text(
                                                    '${times.sunrise != null ? times.sunrise.toString() : ''}',
                                                    style: TextStyle(
                                                      color: theme.onBackground,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Icon(
                                                    Feather.sunset,
                                                    size: 30,
                                                    color: theme.secondary,
                                                  ),
                                                  SizedBox(height: 9.75),
                                                  Text(
                                                    '${times.sunset != null ? times.sunset.toString() : ''}',
                                                    style: TextStyle(
                                                      color: theme.onBackground,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    duration: Duration(milliseconds: 430),
                                    opacity:
                                        _locationStatus == Constants.CONNECTING
                                            ? 1
                                            : 0,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 18.5, bottom: 18.5),
                                      child: Text(
                                        _locationStatus,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Container(
                                    width: 200,
                                    constraints: BoxConstraints(
                                        maxWidth: size.width * .6),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: RaisedButton(
                                              onPressed: () {
                                                if (_status ==
                                                    Constants.CONNECTING) {
                                                  return null;
                                                } else if (_status ==
                                                    Constants.DISCONNECTED) {
                                                  _sshToRaspberryPi();
                                                } else {
                                                  _disconnectClient();
                                                }
                                                // so pretty much display Getting location

                                                // Connecting ..............
                                                // Connected.
                                                // Getting location .............
                                                // "Could not connect to the server.
                                                // Try turning off and turning on the Raspberry Pi or the Wifi Network."
                                              },
                                              child: Text(
                                                _connectButtonText,
                                                style: TextStyle(
                                                  color: theme.onBackground,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  //SizedBox(height: 18.5),
                                  // Container(
                                  //   constraints: BoxConstraints(
                                  //       maxWidth: size.width * .9),
                                  //   child: Row(
                                  //     children: <Widget>[
                                  //       Expanded(
                                  //         child: RaisedButton(
                                  //           color:
                                  //               Color.fromRGBO(88, 94, 108, 1),
                                  //           disabledColor:
                                  //               Color.fromRGBO(78, 84, 98, 1),
                                  //           onPressed: () =>
                                  //               _getCurrentLocation(),
                                  //           child: Text(
                                  //             'Get Location',
                                  //             style: TextStyle(
                                  //               color: theme.onBackground,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       )
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomNavigationBar: BottomNavigationBar(
                      backgroundColor: Color.fromRGBO(58, 65, 80, 1),
                      onTap: (int index) {
                        if (index == 0) {
                          Navigator.pushNamed(context, '/dashboard');
                        }

                        if (index == 1) {
                          Navigator.pushNamed(context, '/status');
                        }
                      },
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.dashboard, color: theme.secondary),
                          title: Text(''),
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Zocial.statusnet, color: theme.secondary),
                          title: Text(''),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                _widget = LoadingScreen();
              }

              return _widget;
            });
          },
        );
      },
    );
  }
}
