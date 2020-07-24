import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ssh/ssh.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../../services/loading.service.dart';
import '../../globals.dart';
import '../../services/storage.service.dart';
import '../../constants.dart';
import '../../services/authentication.service.dart';
import '../../services/database.service.dart';
import '../../services/raspberrypi_service.dart';
import '../../services/position_service.dart';
import '../../services/solar_service.dart';
import '../../widgets/AppBars/signed_in_app_bar.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';
import '../../error_dialog.dart';
import './styles.dart';
import '../../theme.dart';
import '../../wait.dart';
import '../../state/user_model.dart';
import '../../__private_config__.dart';
import '../../sun_tracking_files/sun_tracking.dart';
import '../../sun_tracking_files/tilt.dart';

class Status extends StatefulWidget {
  Status({Key key}) : super(key: key);

  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> with TickerProviderStateMixin {
  // with SingleTickerProviderStateMixin {
  final Globals _globals = Globals();
  final AuthenticationService _authService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final LoadingService _loadingService = LoadingService();
  final RaspberryPiService _raspberryPiService = RaspberryPiService();
  final PositionService _positionService = PositionService();
  final SolarService _solarService = SolarService();

  UserModel _userModel;
  PageController _pageController;
  Position _currentPosition;
  String _username = '';
  String _pythonResponse = '';
  String _location = Constants.LOCATION_NOT_AVAILABLE;
  String _sshStatus = Constants.SSH_DISCONNECTED;

  int _currentPage = 0;
  bool displayDashboardContent = false;
  bool _connectingToClient = false;
  bool _sshWorked = false;
  bool _processWorked = false;
  bool _gettingLocation = false;

  final client = SSHClient(
    host: '192.168.43.52',
    port: 22,
    username: 'pi',
    passwordOrKey: Config.password,
  );

  @override
  void initState() {
    super.initState();
  }

  _handlePageChanged(int value) {
    setState(() => _currentPage = value);
  }

  Future<void> _sshToRaspberryPi() async {
    setState(() {
      _connectingToClient = true;
      _sshStatus = Constants.SSH_CONNECTING;
    });
    try {
      final connected = await _raspberryPiService.connect();
      if (connected is String) {
        setState(() => _sshStatus = Constants.SSH_CONNECTED);
      } else {}
    } catch (error) {
      print('An error occurred connecting to the client $error');
      // displayErrorDialog();
      setState(() {
        _sshStatus = Constants.SSH_DISCONNECTED;
      });
    }

    setState(() => _connectingToClient = false);
  }

  _disconnectClient() {
    _raspberryPiService.disconnect();
    setState(() {
      _sshStatus = Constants.SSH_DISCONNECTED;
      _currentPosition = null;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);

    try {
      final Position position = await _positionService.getCurrentPosition();
      setState(() => _currentPosition = position);
    } catch (error) {
      print('An error occurred in getCurrentPosition() $error');
    }

    setState(() => _gettingLocation = false);
  }

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

  Future<dynamic> _displayCreateAccountDialog() {
    final styles = Styles.alertDialog;

    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        final Size size = MediaQuery.of(context).size;
        final AppTheme theme = Provider.of<AppTheme>(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          titlePadding: styles['titlePadding'],
          buttonPadding: styles['buttonPadding'],
          contentPadding: styles['contentPadding'],
          backgroundColor: Colors.white,
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: theme.secondary,
            ),
            padding: EdgeInsets.fromLTRB(
              size.width * .1,
              size.width * .125,
              size.width * .1,
              size.width * .125,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'Would you like to create an account to save your progress?',
              style: TextStyle(
                fontSize: 22,
                height: 1.4,
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () async {
                await wait(ms: 800);
                await _pageController.nextPage(
                  duration: Duration(milliseconds: 215),
                  curve: Curves.easeIn,
                );
                Navigator.of(context).pop();
              },
            ),
            GestureDetector(
              child: Text(
                'No',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                Navigator.of(context).pop();
                // hide the main content?
                // display the nickname page?
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);

    return Consumer<UserModel>(
      builder: (context, user, child) {
        print('Dashboard Consumer user $user ${user.platform}');
        String displayName = user.platform == Constants.EMAIL_OR_USERNAME
            ? user.username
            : user.nickname;

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
                        ? SignedInAppBar(
                            title: '',
                            automaticallyImplyLeading: false,
                            backgroundColor: theme.background,
                            elevation: 0.0,
                          )
                        : null,
                    body: Container(
                      height: size.height,
                      width: size.width,
                      color: Color.fromRGBO(30, 30, 30, 1),
                      child: OrientationBuilder(
                        builder: (
                          BuildContext context,
                          Orientation orientation,
                        ) {
                          return Column(
                            children: <Widget>[
                              Expanded(
                                child: GridView.count(
                                  primary: false,
                                  padding: EdgeInsets.all(0),
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 0,
                                  childAspectRatio:
                                      orientation == Orientation.portrait
                                          ? .79
                                          : 1.5,
                                  crossAxisCount:
                                      orientation == Orientation.portrait
                                          ? 2
                                          : 2,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () async {
                                        print(
                                            'Status onTap() $_sshStatus $_connectingToClient');
                                        if (_connectingToClient) {
                                          return null;
                                        } else if (_sshStatus ==
                                            Constants.SSH_DISCONNECTED) {
                                          _sshToRaspberryPi();
                                        } else {
                                          print(
                                              '_sshStatus is Connected, calling _disconnectClient()');
                                          _disconnectClient();
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.secondary,
                                          border: Border.all(
                                            width: 2.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                //color: Colors.red,
                                                height: 70,
                                                child: Icon(
                                                  Icons.settings_remote,
                                                  color: Colors.white,
                                                  size: 40.0,
                                                ),
                                              ),
                                              Container(
                                                //color: Colors.blue,
                                                height: 35,
                                                child: Text(
                                                  'Status',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22.25,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 60,
                                                //color: Colors.green,
                                                child: Text(
                                                  _sshStatus,
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    /**
                                     * Location
                                     */
                                    GestureDetector(
                                      onTap: () async {
                                        if (_connectingToClient) {
                                          return null;
                                        } else {
                                          await _getCurrentLocation();
                                        }
                                      },
                                      child: AnimatedOpacity(
                                        duration: Duration(milliseconds: 215),
                                        opacity: (_sshStatus ==
                                                    Constants
                                                        .SSH_DISCONNECTED &&
                                                _currentPosition == null)
                                            ? 0.15
                                            : 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(98, 98, 254, 1),
                                            border: Border.all(
                                              width: 2.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  //color: Colors.red,
                                                  height: 70,
                                                  child: Icon(
                                                    Icons.location_searching,
                                                    color: Colors.white,
                                                    size: 40.0,
                                                  ),
                                                ),
                                                Container(
                                                  //color: Colors.blue,
                                                  height: 35,
                                                  child: Text(
                                                    'Location',
                                                    style: TextStyle(
                                                      color: theme.onBackground,
                                                      fontSize: 22.25,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: 60,
                                                  //color: Colors.green,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        'Lat: ${_currentPosition != null ? _currentPosition.latitude.toString() : Constants.LOCATION_NOT_AVAILABLE}',
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Long: ${_currentPosition != null ? _currentPosition.longitude.toString() : Constants.LOCATION_NOT_AVAILABLE}',
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    /**
                                     * Magnetic Declination
                                     */
                                    GestureDetector(
                                      onTap: () async {
                                        if (_connectingToClient) {
                                          return null;
                                        } else {
                                          await _getCurrentLocation();
                                        }
                                      },
                                      child: AnimatedOpacity(
                                        duration: Duration(milliseconds: 215),
                                        opacity:
                                            _currentPosition == null ? 0.15 : 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(254, 98, 254, 1),
                                            border: Border.all(
                                              width: 2.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  //color: Colors.red,
                                                  height: 70,
                                                  child: Icon(
                                                    FontAwesome.compass,
                                                    color: Colors.white,
                                                    size: 40.0,
                                                  ),
                                                  // Icon(
                                                  //   Icons.settings_remote,
                                                  //   color: Colors.white,
                                                  //   size: 40.0,
                                                  // ),
                                                ),
                                                Container(
                                                  //color: Colors.blue,
                                                  height: 35,
                                                  child: Text(
                                                    'Declination',
                                                    style: TextStyle(
                                                      color: theme.onBackground,
                                                      fontSize: 22.25,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: 60,
                                                  //color: Colors.green,
                                                  child: Text(
                                                    _sshStatus,
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (_connectingToClient) {
                                          return null;
                                        } else {
                                          //
                                        }
                                      },
                                      child: AnimatedOpacity(
                                        duration: Duration(milliseconds: 215),
                                        opacity:
                                            _currentPosition == null ? 0.15 : 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(98, 254, 254, 1),
                                            border: Border.all(
                                              width: 2.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                // Container(
                                                //   //color: Colors.red,
                                                //   height: 70,
                                                //   child: Icon(
                                                //     Icons.settings_remote,
                                                //     color: Colors.white,
                                                //     size: 40.0,
                                                //   ),
                                                // ),
                                                Container(
                                                  //color: Colors.blue,
                                                  height: 52.5,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        'Sunrise',
                                                        style: TextStyle(
                                                          color: theme
                                                              .onBackground,
                                                          fontSize: 22.25,
                                                        ),
                                                      ),
                                                      Text(
                                                        '7:00am',
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  //color: Colors.blue,
                                                  height: 52.5,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        'Sunset',
                                                        style: TextStyle(
                                                          color: theme
                                                              .onBackground,
                                                          fontSize: 22.25,
                                                        ),
                                                      ),
                                                      Text(
                                                        '7:00am',
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    bottomNavigationBar: BottomNavigationBar(
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
