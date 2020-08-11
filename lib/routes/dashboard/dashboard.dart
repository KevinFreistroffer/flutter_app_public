import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_keto/actions/loading_actions.dart';
import 'package:flutter_keto/actions/raspberry_pi_actions.dart';
import 'package:flutter_keto/actions/solar_actions.dart';
import 'package:flutter_keto/routes/dashboard/widgets/title_value.dart';
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
import 'package:redux/redux.dart';
import 'package:intl/intl.dart';
import 'package:flutter_keto/route_observer.dart';

import 'package:flutter_keto/globals.dart';
import 'package:flutter_keto/services/storage.service.dart';
import 'package:flutter_keto/constants.dart';
import 'package:flutter_keto/services/authentication.service.dart';
import 'package:flutter_keto/services/database.service.dart';
import 'package:flutter_keto/services/raspberrypi_service.dart';
import 'package:flutter_keto/services/solar_service.dart';
import 'package:flutter_keto/services/position_service.dart';
import 'package:flutter_keto/services/times_service.dart';
import 'package:flutter_keto/services/permission_handler_service.dart';
import 'package:flutter_keto/widgets/AppBars/signed_in_app_bar.dart';
import 'package:flutter_keto/widgets/loading_screen/LoadingScreen.dart';
import 'package:flutter_keto/actions/position_actions.dart';
import 'package:flutter_keto/actions/times_actions.dart';
import 'package:flutter_keto/error_dialog.dart';
import './styles.dart';
import 'package:flutter_keto/theme.dart';
import 'package:flutter_keto/wait.dart';
import 'package:flutter_keto/__private_config__.dart';
import 'tabs/connection.dart';
import 'tabs/tracking.dart';

import 'package:flutter_keto/state/app_state.dart';
import 'package:flutter_keto/state/times_state.dart';
import 'package:flutter_keto/state/position_state.dart';
import 'package:flutter_keto/state/raspberry_pi_state.dart';
import 'package:flutter_keto/store.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_keto/error_dialog.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin, RouteAware {
  // with SingleTickerProviderStateMixin {
  final Globals _globals = Globals();
  final AuthenticationService _authService = AuthenticationService();
  final RPiService _piService = RPiService();
  final SolarService _solarService = SolarService();
  final PositionService _positionService = PositionService();
  final TimesService _timesService = TimesService();
  final PermissionHandlerService _permissionService =
      PermissionHandlerService();

  bool displayDashboardContent = false;
  AppTheme theme;
  dynamic _selectedTime;

  @override
  void initState() {}

  @override
  void dispose() {
    if (store.state.rPiState.scriptRunning) {
      _exitTheScript().then((_) async {
        await _disconnectFromRaspberryPi();
        store.dispatch(
          SetSSHStatusAction(sshStatus: Constants.SSH_DISCONNECTED),
        );
        store.dispatch(SetScriptStatusAction(scriptRunning: false));
        store.dispatch(SetAutoStartValuesAction(
          autoStart: false,
          autoStartAtSunrise: false,
          autoStartTime: null,
          autoStartTimeAsString: '',
        ));
      });
    }

    routeObserver.unsubscribe(this);

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    theme = Provider.of(context);
    routeObserver.subscribe(this, ModalRoute.of(context));
    _permissionService.requestPermission(Permission.location).then(
      (status) async {
        store.dispatch(
          SetLoadingValuesAction(
            isOpen: false,
            showIcon: false,
            title: '',
            text: '',
          ),
        );
        await _getCoordinates();
        await _getTimes();
        await _getSolarValues();
      },
    );
  }

  @override
  void didPush() {
    RPiState state = store.state.rPiState;

    if (state.autoStart && state.autoStartTime != null) {
      _timesService
          .isWithinTwilightHours(time: state.autoStartTime)
          .then((bool isWithin) async {
        if (isWithin) await _startAutoStartTimer();
      });
    }
  }

  @override
  void didPopNext() {
    RPiState state = store.state.rPiState;

    if (state.autoStart && state.autoStartTime != null) {
      _timesService
          .isWithinTwilightHours(time: state.autoStartTime)
          .then((bool isWithin) async {
        if (isWithin) await _startAutoStartTimer();
      });
    }
  }

  Future<void> _startAutoStartTimer() async {
    RPiState state = store.state.rPiState;

    if (state.autoStart && state.autoStartTime != null) {
      Timer.periodic(Duration(seconds: 1), (timer) async {
        final autoStartTime = TimeOfDay(
            hour: state.autoStartTime.hour, minute: state.autoStartTime.minute);
        final now = DateTime.now().toLocal();

        final isAtSameMoment = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute,
        ).isAtSameMomentAs(
          DateTime(
            now.year,
            now.month,
            now.day,
            autoStartTime.hour,
            autoStartTime.minute,
          ),
        );

        if (isAtSameMoment) await _startTheScript(timer: timer);
      });
    }
  }

  Future<void> _getCoordinates() async {
    // call position or coords service
    final Position position = await _positionService.getCurrentPosition();

    if (position != null) {
      store.dispatch(
        SetCoordinatesAction(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    }
    // coordsModel.set()
  }

  Future<void> _getTimes() async {
    final Position position = await _positionService.getCurrentPosition();

    if (position != null) {
      try {
        final timesResponse = await _timesService.getSunriseAndSunset(
          position.latitude,
          position.longitude,
        );

        if (timesResponse != null) {
          final data = timesResponse.data;

          store.dispatch(
            SetTimesAction(
              sunrise: data.sunrise.toLocal(),
              sunset: data.sunset.toLocal(),
              dayLength: data.dayLength,
            ),
          );
        }
      } catch (error) {
        if (error.toString().contains('Http')) {
          _displayErrorDialog(
            'An error occured. Please check your internet connection, or try later.',
          );
        }
      }
    }
  }

  Future<void> _getSolarValues() async {
    try {
      final solarValues = await _solarService.getSolarValues();
      final magneticDeclination =
          await _positionService.getMagneticDeclination();
      store.dispatch(
        SetSolarValuesAction(
          solarValues['azimuth'],
          solarValues['zenith'],
          magneticDeclination,
        ),
      );
    } catch (error) {
      print(
        'An error occurred in SolarService.getSolarValues() ${error.toString()}',
      );
      _displayErrorDialog(error.toString());
    }
  }

  Future<void> _sshToRaspberryPi() async {
    store.dispatch(SetSSHStatusAction(sshStatus: Constants.SSH_CONNECTING));

    var response = await _piService.connect().timeout(
      Duration(seconds: 20),
      onTimeout: () async {
        store.dispatch(
          SetSSHStatusAction(sshStatus: Constants.SSH_DISCONNECTED),
        );

        throw ('Could not connect. \n Please make sure the Raspberry Pi is turned on and on the same network as this divice.');
      },
    ).catchError((e) {
      print('_RPiService.connect() catchError block $e');

      String errorMessage;
      if (e.toString().contains('Connection refused')) {
        errorMessage = Constants.ERROR_SSH_CONNECTION_REFUSED;
      } else if (e.toString().contains('Network is unreachable')) {
        errorMessage = Constants.ERROR_SSH_NETWORK_UNREACHABLE;
      } else if (e.toString().contains('Software caused connection abort')) {
        errorMessage = Constants.ERROR_SSH_SOFTWARE_CAUSED_CONNECTION_ABORT;
      } else {
        errorMessage = Constants.ERROR_SSH_GENERIC;
      }
      store.dispatch(SetSSHStatusAction(sshStatus: Constants.SSH_DISCONNECTED));

      _displayErrorDialog(errorMessage);
    });

    if (response == Constants.SSH_CONNECT_SUCCESS) {
      store.dispatch(SetSSHStatusAction(sshStatus: Constants.SSH_CONNECTED));
    }
    // } else {
    //   setState(() => _sshStatus = Constants.SSH_DISCONNECTED);

    //   _displayErrorDialog(response.toString(), barrierDismissible: true);
    // }
  }

  Future<void> _disconnectFromRaspberryPi() async {
    await _piService.disconnect();

    store.dispatch(SetSSHStatusAction(sshStatus: Constants.SSH_DISCONNECTED));
    store.dispatch(SetScriptStatusAction(scriptRunning: false));
    store.dispatch(SetAutoStartValuesAction(
      autoStart: false,
      autoStartAtSunrise: false,
      autoStartTime: null,
      autoStartTimeAsString: '',
    ));
  }

  Future<void> _startTheScript({Timer timer}) async {
    // Handles if the script is started automatically
    // and cancels the timer to prevent recalling startScript repeatedly
    if (timer != null) timer.cancel();

    bool isWithinTwilightHours = await _timesService.isWithinTwilightHours(
      time: store.state.rPiState.autoStartTime,
    );

    try {
      if (true) {
        var now = DateTime.now().toLocal();

        var state = store.state;

        print('startTheScript()');
        print(state.positionState.latitude);
        print(state.positionState.longitude);

        // var sunriseDateTime = DateTime(
        //   now.year,
        //   now.month,
        //   now.day,
        //   state.timesState.sunrise.toLocal().hour,
        //   state.timesState.sunrise.toLocal().minute,
        // );

        // var sunsetDateTime = DateTime(
        //   now.year,
        //   now.month,
        //   now.day,
        //   state.timesState.sunset.toLocal().hour,
        //   state.timesState.sunset.toLocal().minute,
        // );

        store.dispatch(SetScriptStatusAction(scriptRunning: true));
        final scriptResponse =
            await _piService.startScript().catchError((error) {
          print('An error occurred in RPiService.startScript() error $error');
          _displayErrorDialog(error.toString());
        });

        print('script response $scriptResponse');

        // Successfully completed the script
        if (scriptResponse == Constants.SCRIPT_COMPLETED) {
          store.dispatch(SetScriptStatusAction(scriptRunning: false));
        }
      } else {
        var sunrise = store.state.timesState.sunrise;
        store.dispatch(
          SetAutoStartValuesAction(
              autoStart: true,
              autoStartAtSunrise: true,
              autoStartTime:
                  TimeOfDay(hour: sunrise.hour, minute: sunrise.minute),
              autoStartTimeAsString:
                  '${sunrise.hour > 12 ? sunrise.hour - 12 : sunrise.hour}:${sunrise.minute < 10 ? '0${sunrise.minute}' : sunrise.minute}am'),
        );
        store.dispatch(StartAsyncAutoStartTimerAction());
        _displayWillAutoStartAtTomorrowsSunrise();
      }
    } catch (error) {
      print('An error occurred calling startScript $error');
      store.dispatch(SetScriptStatusAction(scriptRunning: false));
    }
  }

  Future<void> _exitTheScript() async {
    final response = await _piService.exitTheScript();
    // On any response, success or error, just stop the script.
    if (response == Constants.SCRIPT_EXITED) {
      // successfully exited without any errors
    } else {
      // an error occured.
    }

    store.dispatch(SetScriptStatusAction(scriptRunning: false));

    if (store.state.rPiState.autoStart) {
      store.dispatch(
        SetAutoStartValuesAction(
          autoStart: false,
          autoStartAtSunrise: false,
          autoStartTime: null,
          autoStartTimeAsString: '',
        ),
      );
      store.dispatch(StopAsyncAutoStartTimerAction());
    }
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
          backgroundColor: theme.background,
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
            color: theme.background,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  for (var s in strings)
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: theme.onBackground,
                        ),
                      ),
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
                    color: theme.onBackground),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  _displayWillAutoStartAtTomorrowsSunrise() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('The tracking will start \n at tomorrows sunrise'),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Okay'),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> _onPressedToggleScript() async {
    // If not connected to the pi, than the button press does nothing
    // should be if in the process of running the script, the button does nothing
    if (store.state.rPiState.sshStatus == Constants.SSH_CONNECTED) {
      if (!store.state.rPiState.scriptRunning) {
        await _startTheScript();
      } else {
        await _exitTheScript();
      }
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    //final AppTheme theme = Provider.of<AppTheme>(context);

    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          TimesState timesState = state.timesState;
          RPiState piState = state.rPiState;
          String sunrise = 'N/A';
          String sunset = 'N/A';
          String dayLength = 'N/A';
          DateFormat dateFormat = DateFormat('h:mm:ss');
          /**
           * the angle is determined on the total range, the total duration of the time,
           * the minutes since sunrise and that percentage within the total range
           * 
           */
          if (timesState.sunrise != null) {
            sunrise = dateFormat.format(timesState.sunrise);
          }
          if (timesState.sunset != null) {
            sunset = dateFormat.format(timesState.sunset);
          }

          if (state.timesState.dayLength != null) {
            final hours = Duration(seconds: timesState.dayLength).inHours;
            final minutes =
                Duration(seconds: timesState.dayLength).inMinutes.remainder(60);
            final seconds =
                Duration(seconds: timesState.dayLength).inSeconds.remainder(60);
            dayLength = ' ${hours}h ${minutes}m ${seconds}s';
          }

          return OrientationBuilder(
            builder: (context, orientation) {
              final Size size = MediaQuery.of(context).size;

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
                            top: BorderSide(
                              color: Colors.black.withOpacity(0.05),
                            ),
                            bottom: BorderSide(
                              color: Colors.black.withOpacity(0.05),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Opacity(
                              opacity:
                                  piState.sshStatus != Constants.SSH_CONNECTED
                                      ? 0.5
                                      : 1,
                              child: RaisedButton(
                                color: Colors.blue,
                                child: Text(
                                  piState.scriptRunning ? 'Stop' : 'Start',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  _onPressedToggleScript();
                                },
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                piState.sshStatus == Constants.SSH_CONNECTING
                                    ? SpinKitRing(
                                        color: Colors.black.withOpacity(0.5),
                                        size: 14,
                                        lineWidth: 2,
                                      )
                                    : Text(
                                        piState.sshStatus,
                                        style: GoogleFonts.notoSans(
                                          fontSize: size.width < 800 ? 13 : 22,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                Switch(
                                  value: piState.sshStatus ==
                                          Constants.SSH_CONNECTED
                                      ? true
                                      : false,
                                  onChanged: (bool isOn) async {
                                    isOn
                                        ? await _sshToRaspberryPi()
                                        : await _disconnectFromRaspberryPi();
                                  },
                                  activeTrackColor: Colors.blue,
                                  activeColor: Colors.white,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Visibility(
                              visible: state.rPiState.sshStatus ==
                                  Constants.SSH_DISCONNECTED,
                              child: Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Text(
                                      'Connect in the upper right hand corner',
                                      style: TextStyle(
                                        fontSize:
                                            orientation == Orientation.portrait
                                                ? size.width * .04
                                                : 24,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: state.rPiState.sshStatus ==
                                  Constants.SSH_CONNECTED,
                              child: Expanded(
                                flex: 1,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Opacity(
                                        opacity: state.rPiState.sshStatus ==
                                                    Constants.SSH_CONNECTED &&
                                                !state.rPiState.scriptRunning
                                            ? 1
                                            : 0.5,
                                        child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(16, 8, 16, 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (state.rPiState.sshStatus ==
                                                      Constants.SSH_CONNECTED &&
                                                  !state
                                                      .rPiState.scriptRunning) {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/auto-start',
                                                );
                                              } else {
                                                return null;
                                              }
                                            },
                                            child: Container(
                                              width: size.width,
                                              padding: EdgeInsets.only(
                                                  top: 8, bottom: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'Setup Auto Start',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        .merge(
                                                          TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                size.width < 800
                                                                    ? 16
                                                                    : 22,
                                                          ),
                                                        ),
                                                  ),
                                                  Text(
                                                    piState.autoStartTimeAsString
                                                            .isEmpty
                                                        ? 'Not Set'
                                                        : '${'${piState.autoStartTimeAsString}'}',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            color: Color.fromRGBO(
                                                232, 234, 237, 1),
                                            padding: EdgeInsets.fromLTRB(
                                                8, 16, 8, 8),
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  'CONNECTION DETAILS',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                16, 8, 16, 8),
                                            child: TitleValue(
                                              'Status',
                                              state.rPiState.scriptRunning
                                                  ? Constants.SCRIPT_RUNNING
                                                  : Constants
                                                      .SCRIPT_NOT_RUNNING,
                                            ),
                                          ),
                                          Divider(color: Colors.black12),
                                          Opacity(
                                            opacity:
                                                !state.rPiState.scriptRunning
                                                    ? 0.25
                                                    : 1,
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  16, 8, 16, 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  TitleValue(
                                                    'Latitude',
                                                    state.positionState
                                                                .latitude !=
                                                            null
                                                        ? state.positionState
                                                            .latitude
                                                            .toStringAsFixed(3)
                                                        : 'N/A',
                                                  ),
                                                  Divider(
                                                    color: Colors.black12,
                                                  ),
                                                  TitleValue(
                                                      'Longitude',
                                                      state.positionState
                                                                  .longitude !=
                                                              null
                                                          ? state.positionState
                                                              .longitude
                                                              .toStringAsFixed(
                                                                  3)
                                                          : 'N/A'),
                                                  Divider(
                                                    color: Colors.black12,
                                                  ),
                                                  TitleValue(
                                                    'Sunrise',
                                                    '$sunrise AM',
                                                  ),
                                                  Divider(
                                                    color: Colors.black12,
                                                  ),
                                                  TitleValue(
                                                    'Sunset',
                                                    '$sunset PM',
                                                  ),
                                                  Divider(
                                                    color: Colors.black12,
                                                  ),
                                                  TitleValue(
                                                    'Daylight Duration',
                                                    dayLength,
                                                  ),
                                                  Divider(
                                                    color: Colors.black12,
                                                  ),

                                                  TitleValue(
                                                      'Azimuth',
                                                      state.solarState
                                                                  .azimuth !=
                                                              null
                                                          ? state.solarState
                                                              .azimuth
                                                              .toStringAsFixed(
                                                                  3)
                                                          : 'N/A'),
                                                  Divider(
                                                    color: Colors.black12,
                                                  ),
                                                  TitleValue(
                                                      'Altitude',
                                                      state.solarState.zenith !=
                                                              null
                                                          ? state
                                                              .solarState.zenith
                                                              .toStringAsFixed(
                                                                  3)
                                                          : 'N/A'),
                                                  Divider(
                                                    color: Colors.black12,
                                                  ),
                                                  // TitleValue(
                                                  //   'Altitude',
                                                  //   state.solarState.altitude !=
                                                  //           null
                                                  //       ? state
                                                  //           .solarState.altitude
                                                  //           .toStringAsFixed(3)
                                                  //       : 'N/A',
                                                  // ),
                                                  // Divider(
                                                  //   color: Colors.black12,
                                                  // ),
                                                  TitleValue(
                                                    'Magnetic Declination',
                                                    state.solarState
                                                                .magneticDeclination !=
                                                            null
                                                        ? state.solarState
                                                            .magneticDeclination
                                                            .toStringAsFixed(3)
                                                        : 'N/A',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
                                  color: !state.rPiState.scriptRunning
                                      ? Color.fromRGBO(232, 234, 237, 1)
                                      : Colors.blue,
                                ),
                                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      state.rPiState.scriptRunning
                                          ? Constants.SCRIPT_RUNNING
                                          : Constants.SCRIPT_NOT_RUNNING,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Switch(
                                      value: state.rPiState.scriptRunning
                                          ? true
                                          : false,
                                      onChanged: (bool isOn) async {
                                        if (isOn) {
                                          await _startTheScript();
                                        } else {
                                          await _exitTheScript();
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
