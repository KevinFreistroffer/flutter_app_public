import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_keto/actions/solar_actions.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ssh/ssh.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_suncalc/flutter_suncalc.dart';
import 'package:sunrise_sunset/sunrise_sunset.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

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
import '../../actions/position_actions.dart';
import '../../actions/times_actions.dart';
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
import '../../models/app_state.dart';
import '../../models/times_state.dart';
import '../../models/position_state.dart';

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
  final TimesService _timesService = TimesService();
  final CoordinatesModel _coordsModel = CoordinatesModel();
  final TimesModel _timesModel = TimesModel();
  String _sshStatus = Constants.SSH_DISCONNECTED;
  String _scriptStatus = Constants.SCRIPT_NOT_RUNNING;
  bool displayDashboardContent = false;
  AppTheme theme;

  @override
  void initState() {
    super.initState();
    _loadingService.add(isOpen: false).then((value) async {
      await _getCoordinates();
      await _getTimes();
      await _getAzimuthAndAltitude();
    });
  }

  @override
  void dispose() {
    if (_scriptStatus == Constants.SCRIPT_RUNNING) {
      _stopScript().then((_) async {
        await _disconnectFromRaspberryPi();
      });
    }

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Provider.of(context);
  }

  Future<void> _getCoordinates() async {
    // call position or coords service
    final Position position = await _positionService.getCurrentPosition();

    print('getCoordinates() position $position');

    if (position != null) {
      print('position != null in _getCoordinates() in dashboard.dart');
      StoreProvider.of<PositionState>(context).dispatch(
        SetCoordinatesAction(position.latitude, position.longitude),
      );
    }
    // coordsModel.set()
  }

  Future<void> _getTimes() async {
    final Position position = await _positionService.getCurrentPosition();

    if (position != null) {
      final response = await _timesService.getSunriseAndSunset(
        position.latitude,
        position.longitude,
      );
      print(
          'timesService response ${response?.data?.sunrise} ${response?.data?.sunset}');
      if (response != null) {
        final data = response.data;

        StoreProvider.of<TimesState>(context).dispatch(
          SetTimesAction(
            sunrise: response.data.sunrise.toLocal(),
            sunset: response.data.sunset.toLocal(),
            dayLength: data.dayLength,
          ),
        );
      }
    }
  }

  Future<void> _getAzimuthAndAltitude() async {
    final azimuthAndAltitude = await _solarService.getAzimuthAndAltitude();
    print('Dashboard getAzimuthAndAltitude $azimuthAndAltitude');
    StoreProvider.of<TimesState>(context).dispatch(
      SetAzimuthAndAltitudeAction(
          azimuthAndAltitude['azimuth'], azimuthAndAltitude['altitude']),
    );
  }

  Future<void> _sshToRaspberryPi() async {
    setState(() => _sshStatus = Constants.SSH_CONNECTING);

    try {
      var response = await _raspberryPiService.connect().timeout(
        Duration(seconds: 8),
        onTimeout: () async {
          setState(() => _sshStatus = Constants.SSH_DISCONNECTED);

          throw ('Could not connect to the server. \n Try turning off the Raspberry Pi, then turning it back on, or reset your network connection.');
        },
      );

      if (response == Constants.SSH_CONNECT_SUCCESS) {
        setState(() => _sshStatus = Constants.SSH_CONNECTED);
      } else {
        setState(() => _sshStatus = Constants.SSH_DISCONNECTED);

        _displayErrorDialog(
          response.toString(),
          barrierDismissible: true,
        );
      }
    } catch (error) {
      print('An error occurred calling .connectToClient() $error');
      setState(() => _sshStatus = Constants.SSH_DISCONNECTED);

      _displayErrorDialog(error.toString());
    }
  }

  Future<void> _disconnectFromRaspberryPi() async {
    await _raspberryPiService.disconnect();
    setState(() {
      _sshStatus = Constants.SSH_DISCONNECTED;
      _scriptStatus = Constants.SCRIPT_NOT_RUNNING;
    });
  }

  Future<void> _startScript() async {
    try {
      Position position = await _positionService.getCurrentPosition();
      dynamic sunriseAndSunset = await _timesService.getSunriseAndSunset(
        position.latitude,
        position.longitude,
      );

      var sunriseDateTime = DateTime(
        2020,
        sunriseAndSunset.data.sunrise.month,
        sunriseAndSunset.data.sunrise.day,
        sunriseAndSunset.data.sunrise.hour,
        sunriseAndSunset.data.sunrise.minute,
      );
      var sunsetDateTime = DateTime(
        2020,
        sunriseAndSunset.data.sunset.month,
        sunriseAndSunset.data.sunset.day,
        sunriseAndSunset.data.sunset.hour,
        sunriseAndSunset.data.sunset.minute,
      );

      Duration twilightDuration = sunsetDateTime.difference(sunriseDateTime);
      Duration minutesSinceSunrise = sunriseDateTime.difference(DateTime.now());

      setState(() => _scriptStatus = Constants.SCRIPT_RUNNING);

      final scriptResponse = await _raspberryPiService.startScript(
        twilightDuration: twilightDuration.inMinutes,
        minutesSinceSunrise: minutesSinceSunrise.inMinutes,
      );

      // Successfully completed the script
      if (scriptResponse == Constants.SCRIPT_COMPLETED) {
        // Probably display
      }

      setState(() => _scriptStatus = Constants.SCRIPT_NOT_RUNNING);
    } catch (error) {
      print('An error occurred in startScript() $error');
      setState(() => _scriptStatus = Constants.SCRIPT_NOT_RUNNING);
    }
  }

  Future<void> _stopScript() async {
    await _raspberryPiService.exitTheScript();
    setState(() => _scriptStatus = Constants.SCRIPT_NOT_RUNNING);
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

  Future<void> _handleOnPressed() async {
    if (true) {
      final Position position = await _positionService.getCurrentPosition();
      Provider.of<CoordinatesModel>(context, listen: false)
          .set(latitude: position.latitude, longitude: position.longitude);
    } else {
      // display Are you sure you want to stop tracking?
      // disconnect()
      // stopScript(); reversed
    }

    await _startScript();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    Widget _widget;
    print('size.width * .5 ${size.width * .5}');

    //final AppTheme theme = Provider.of<AppTheme>(context);

    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          print(
            'Dashboard state: $state ${state.sunrise} ${state.sunset} ${state.dayLength}',
          );

          String sunrise = 'N/A';
          String sunset = 'N/A';
          String dayLength = 'N/A';
          DateFormat dateFormat = DateFormat('h:mm:ss');
          if (state.sunrise != null) {
            sunrise = dateFormat.format(state.sunrise);
          }
          if (state.sunset != null) {
            sunset = dateFormat.format(state.sunset);
          }

          if (state.dayLength != null) {
            var hours = Duration(seconds: state.dayLength).inHours;
            var minutes =
                Duration(seconds: state.dayLength).inMinutes.remainder(60);
            var seconds =
                Duration(seconds: state.dayLength).inSeconds.remainder(60);
            dayLength = ' ${hours}h ${minutes}m ${seconds}s';
          }

          return OrientationBuilder(
            builder: (context, orientation) {
              final Size size = MediaQuery.of(context).size;
              bool sshConnected = _sshStatus == Constants.SSH_DISCONNECTED ||
                      _sshStatus == Constants.SSH_CONNECTING
                  ? false
                  : true;

              return Scaffold(
                  key: _globals.scaffoldKey,
                  backgroundColor: Colors.white,
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(Constants.APP_BAR_HEIGHT),
                    child: SignedInAppBar(
                      title: 'Dashboard',
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      height: 200,
                    ),
                  ),
                  body: Container(
                    width: size.width,
                    height: size.height,
                    constraints: BoxConstraints(
                      minHeight: size.height,
                    ),
                    child: Column(
                      //mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: size.width,
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(232, 234, 237, 1),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(_sshStatus.toUpperCase(),
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Switch(
                                value: _sshStatus == Constants.SSH_CONNECTED,
                                onChanged: (bool value) async {
                                  !sshConnected
                                      ? await _sshToRaspberryPi()
                                      : await _disconnectFromRaspberryPi();
                                },
                                activeTrackColor: Colors.blue,
                                activeColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              children: <Widget>[
                                Visibility(
                                  visible:
                                      _sshStatus == Constants.SSH_DISCONNECTED,
                                  child: Expanded(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(32),
                                        child: Text(
                                          'Connect in the upper right hand corner',
                                          style: TextStyle(
                                            fontSize: orientation ==
                                                    Orientation.portrait
                                                ? size.width * .04
                                                : 24,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Visibility(
                                  visible:
                                      _sshStatus == Constants.SSH_CONNECTED,
                                  child: Expanded(
                                    flex: 1,
                                    child: SingleChildScrollView(
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(16, 8, 16, 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 16, bottom: 16),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        'CONNECTION DETAILS',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  'Status',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  _scriptStatus,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.black12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Latitude',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  state.latitude != null
                                                      ? state.latitude
                                                          .toStringAsFixed(3)
                                                      : 'N/A',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.black12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Longitude',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  state.longitude != null
                                                      ? state.longitude
                                                          .toStringAsFixed(3)
                                                      : 'N/A',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.black12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Sunrise',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '$sunrise AM',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.black12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Sunset',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '$sunset PM',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.black12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Current Angle',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '20°',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.black12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Azimuth',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  state.azimuth
                                                      .toStringAsFixed(3),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.black12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Altitude',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  state.altitude
                                                      .toStringAsFixed(3),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.black12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Twilight Length',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  dayLength,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.black12,
                                            ),
                                            // SizedBox(height: 16),
                                            // Container(
                                            //   width: size.width,
                                            //   child: RaisedButton(
                                            //     color: Colors.grey,
                                            //     onPressed: () {},
                                            //     child: Text(
                                            //       'Clear and Reset',
                                            //       style: TextStyle(
                                            //         color: Colors.white,
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Visibility(
                                  visible: false,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                      color: _scriptStatus !=
                                              Constants.SCRIPT_RUNNING
                                          ? Color.fromRGBO(232, 234, 237, 1)
                                          : Colors.blue,
                                    ),
                                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          _scriptStatus.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Switch(
                                          value: _scriptStatus ==
                                                  Constants.SCRIPT_NOT_RUNNING
                                              ? false
                                              : true,
                                          onChanged: (bool isOff) async {
                                            print('onChanged isOff $isOff');
                                            if (isOff) {
                                              await _startScript();
                                            } else {
                                              await _stopScript();
                                            }
                                          },
                                          activeTrackColor:
                                              Colors.black.withOpacity(0.25),
                                          activeColor: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // if (orientation ==
                                //     Orientation.landscape) ...[
                                //   CustomAppBar()
                                // ],
                                // Expanded(
                                //   child: TabBarView(
                                //     controller: _tabController,
                                //     children: <Widget>[
                                //       Connection(
                                //         connect: _sshToRaspberryPi,
                                //         disconnect:
                                //             _disconnectFromRaspberryPi,
                                //         executeShellCommand: _startScript,
                                //         exitScript: _raspberryPiService
                                //             .exitTheScript,
                                //         controller: _tabController,
                                //         status: _sshStatus,
                                //         locationStatus: _locationStatus,
                                //         error: null,
                                //       ),
                                //       Tracking(
                                //         controller: _tabController,
                                //         status: _sshStatus,
                                //         orientation: orientation,
                                //       ),
                                //       Text(
                                //         'abcdFDSFDSFDSFSDFSDFefg',
                                //         style: TextStyle(
                                //           color: Colors.blue,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottomNavigationBar: _sshStatus == Constants.SSH_CONNECTED
                      ? Container(
                          width: size.width,
                          height: 48,
                          padding: EdgeInsets.all(0),
                          margin: EdgeInsets.all(0),
                          child: RaisedButton(
                            color: Colors.blue,
                            child: Text(
                              _scriptStatus == Constants.SCRIPT_NOT_RUNNING
                                  ? 'START'
                                  : 'STOP',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              if (_scriptStatus ==
                                  Constants.SCRIPT_NOT_RUNNING) {
                                await _startScript();
                              } else {
                                await _stopScript();
                              }
                            },
                          ),
                        )
                      : null);
            },
          );
        });
  }
}
