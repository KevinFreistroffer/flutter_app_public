import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
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
import 'tabs/connection.dart';
import 'tabs/tracking.dart';

import 'widgets/app_bar.dart';

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
  Orientation _orientation;
  double _latitude;
  double _longitude;
  int _tabIndex = 0;
  bool displayDashboardContent = false;
  List _tabs = ["connection", "tracking", "stats"];
  TabController _tabController;
  AppTheme theme;

  // final client = SSHClient(
  //   host: '192.168.43.1',
  //   port: 22,
  //   username: 'raspberrypi',
  //   passwordOrKey: Config.password,
  // );

  @override
  void initState() {
    super.initState();
    _loadingService.add(isOpen: false);
    _tabController = TabController(length: _tabs.length, vsync: this);

    // _setConnectedState(Constants.CONNECTING);
    // _sshToRaspberryPi().then((String result) async {

    //   // if (response == Constants.SSH_CONNECT_SUCCESS) {
    //   //   _loadingService.add(isOpen: true, text: 'Connected');
    //   //   await wait(ms: 1400);
    //   //   _loadingService.add(isOpen: false);
    //   //   _setConnectedState(Constants.CONNECTED);
    //   //   _tabController.animateTo(_tabIndex + 1);

    //   // } else {
    //   //   // error
    //   //   await wait(s: 1);
    //   //   _setConnectedState(Constants.DISCONNECTED);
    //   //   _displayErrorDialog(
    //   //       'Could not connect to the host.\n Try turning off and turning on the Raspberry Pi or the Wifi network.');
    //   //   await _loadingService.add(isOpen: false);
    //   // }
    // });

    // // Future.delayed(Duration(seconds: 3), () {
    // //   _loadingService.add(isOpen: false);
    // // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        });
        break;
      case Constants.CONNECTED:
        setState(() {
          _status = Constants.CONNECTED;
        });
        break;
      case Constants.DISCONNECTED:
        setState(() {
          _status = Constants.DISCONNECTED;
        });
        break;
    }
  }

  Future<void> _sshToRaspberryPi() async {
    setState(() => _status = Constants.CONNECTING);

    try {
      var response = await _raspberryPiService.connect().timeout(
        Duration(seconds: 8),
        onTimeout: () async {
          _setConnectedState(Constants.DISCONNECTED);
          throw ('Could not connect to the server. \n Try turning off the Raspberry Pi, then turning it back on, or reset your network connection.');
        },
      );

      if (response == Constants.SSH_CONNECT_SUCCESS) {
        _setConnectedState(Constants.CONNECTED);
      } else {
        _setConnectedState(Constants.DISCONNECTED);
        _displayErrorDialog(
          response.toString(),
          barrierDismissible: true,
        );
      }
    } catch (error) {
      print('An error occurred calling .connectToClient() $error');
      _displayErrorDialog(error.toString());
    }
  }

  _disconnectFromRaspberryPi() {
    _raspberryPiService.disconnect();
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

  Future<void> _startScript() async {
    Position position = await _positionService.getCurrentPosition();
    String scriptResponse = await _raspberryPiService.startScript(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    print('scriptResponse $scriptResponse');
    // try {
    //   //SSHClient client = _raspberryPiService.getClient();
    //   _raspberryPiService.startPythonScript();
    // } catch (error) {
    //   print(error.toString());
    // }
  }

  _displayErrorDialog(
    String error, {
    bool barrierDismissible = true,
  }) {
    final LineSplitter ls = LineSplitter();
    final styles = ErrorDialogStyles.alertDialog;

    // split the string at the \n, output a new Text().SizedBox(height)
    List strings = ls.convert(error);
    strings = strings.map((s) => s.trim()).toList();

    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible, // user must tap button!
      builder: (BuildContext context) {
        final Size size = MediaQuery.of(context).size;
        final isPortrait = size.width <
            size.height; // hacky. how to access orientation? OrientationModel?

        return AlertDialog(
          backgroundColor: theme.primaryVariant,
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
              isPortrait ? size.height * .05 : size.height * .025,
              size.width * .1,
              isPortrait ? size.height * .05 : size.height * .025,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.error,
                  size: isPortrait ? 60 : 35,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          titlePadding: styles['titlePadding'],
          buttonPadding: styles['buttonPadding'],
          contentPadding: styles['contentPadding'],
          content: Container(
            constraints: BoxConstraints(
              maxWidth: 150,
            ),
            color: theme.primaryVariant,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  for (var s in strings)
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(s),
                    )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              child: Text(
                'DISMISS',
                style: TextStyle(
                    fontSize: styles['actions']['flatButton']['text']
                        ['fontSize'],
                    fontWeight: styles['actions']['flatButton']['text']
                        ['fontWeight'],
                    color: theme.onPrimaryVariant),
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
        // String latitude = coordinates.latitude != null
        //     ? coordinates.latitude.toStringAsFixed(3)
        //     : 'N/A';
        // String longitude = coordinates.longitude != null
        //     ? coordinates.longitude.toStringAsFixed(3)
        //     : 'N/A';

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
                  _widget = LoadingScreen(
                    title: snapshot.data['title'],
                    text: snapshot.data['text'],
                    showIcon: snapshot.data['showIcon'],
                    showSuccessIcon: snapshot.data['showSuccessIcon'],
                    size: snapshot.data['size'],
                    customIcon: SpinKitRipple(
                      color: theme.onBackground,
                      size: 50.0,
                    ),
                  );
                } else {
                  _widget = OrientationBuilder(
                    builder: (context, orientation) {
                      final Size size = MediaQuery.of(context).size;

                      return Scaffold(
                          key: _globals.scaffoldKey,
                          appBar: orientation == Orientation.portrait
                              ? PreferredSize(
                                  preferredSize:
                                      Size.fromHeight(Constants.APP_BAR_HEIGHT),
                                  child: SignedInAppBar(
                                    title: 'SunScript',
                                    automaticallyImplyLeading: false,
                                    backgroundColor: theme.background,
                                    elevation: 0,
                                    height: 200,
                                  ),
                                )
                              : null,
                          body: LayoutBuilder(
                            builder: (context, viewportConstraints) {
                              return SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: orientation ==
                                          Orientation.portrait
                                      ? BoxConstraints(
                                          minHeight:
                                              viewportConstraints.maxHeight,
                                          maxHeight:
                                              viewportConstraints.maxHeight,
                                        )
                                      : BoxConstraints.loose(size
                                          //minHeight: viewportConstraints.maxHeight,
                                          //maxHeight: viewportConstraints.maxHeight,
                                          ),
                                  child: Column(
                                    //mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      if (orientation ==
                                          Orientation.landscape) ...[
                                        CustomAppBar()
                                      ],
                                      Expanded(
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: <Widget>[
                                            Connection(
                                              connect: _sshToRaspberryPi,
                                              disconnect:
                                                  _disconnectFromRaspberryPi,
                                              executeShellCommand: _startScript,
                                              exitScript: _raspberryPiService
                                                  .exitTheScript,
                                              controller: _tabController,
                                              status: _status,
                                              error: null,
                                            ),
                                            Tracking(
                                              controller: _tabController,
                                              status: _status,
                                              orientation: orientation,
                                            ),
                                            Text(
                                              'abcdFDSFDSFDSFSDFSDFefg',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          bottomNavigationBar: _status == Constants.CONNECTED
                              ? BottomNavigationBar(
                                  onTap: (int index) {
                                    _tabController.animateTo(index);
                                  },
                                  backgroundColor: theme.background,
                                  items: <BottomNavigationBarItem>[
                                    BottomNavigationBarItem(
                                      title: Text(''),
                                      icon: Icon(
                                        Entypo.signal,
                                        color: theme.onBackground,
                                      ),
                                    ),
                                    BottomNavigationBarItem(
                                      title: Text(''),
                                      icon: Icon(
                                        Entypo.direction,
                                        color: theme.onBackground,
                                      ),
                                    ),
                                    BottomNavigationBarItem(
                                      title: Text(''),
                                      icon: Icon(
                                        Feather.activity,
                                        color: theme.onBackground,
                                      ),
                                    ),
                                  ],
                                )
                              : null);
                    },
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
