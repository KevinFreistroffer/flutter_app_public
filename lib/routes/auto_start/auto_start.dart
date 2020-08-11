import 'package:flutter/material.dart';
import 'package:flutter_keto/widgets/AppBars/signed_in_app_bar.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_keto/state/app_state.dart';
import 'package:flutter_keto/actions/raspberry_pi_actions.dart';
import 'package:flutter_keto/routes/dashboard/widgets/title_value.dart';
import 'package:flutter_keto/store.dart';

class AutoStart extends StatefulWidget {
  AutoStart({Key key}) : super(key: key);

  @override
  _AutoStartState createState() => _AutoStartState();
}

class _AutoStartState extends State<AutoStart> {
  bool _autoStart = false;
  bool _autoStartAtSunrise = false;
  dynamic _time;
  String _timeAsString;

  _handleAutoStartOnChange(bool value) {
    // update store state as autoStart as true
    setState(() => _autoStart = !_autoStart);
    store.dispatch(SetAutoStartValuesAction(
      autoStart: !store.state.rPiState.autoStart,
      autoStartAtSunrise: store.state.rPiState.autoStartAtSunrise,
      autoStartTime: !value ? null : store.state.rPiState.autoStartTime,
      autoStartTimeAsString: store.state.rPiState.autoStartTimeAsString,
    ));
  }

  _handleAutoStartAtSunriseOnChange(bool isOn) {
    // update store state as autoStartAtSunrise as true
    setState(() => _autoStartAtSunrise = !_autoStartAtSunrise);
    String autoStartTimeAsString;
    if (isOn) {
      var sunrise = store.state.timesState.sunrise;
      var hour = sunrise.hour > 12 ? sunrise.hour - 12 : sunrise.hour;
      var minute = sunrise.minute < 10 ? '0${sunrise.minute}' : sunrise.minute;
      autoStartTimeAsString = '$hour:${minute}am';
    } else {
      autoStartTimeAsString = store.state.rPiState.autoStartTimeAsString;
    }
    store.dispatch(
      SetAutoStartValuesAction(
        autoStart: store.state.rPiState.autoStart,
        autoStartAtSunrise: !store.state.rPiState.autoStartAtSunrise,
        autoStartTimeAsString: autoStartTimeAsString,
        autoStartTime: !isOn
            ? null
            : TimeOfDay.fromDateTime(store.state.timesState.sunrise),
      ),
    );
    store.dispatch(isOn
        ? StartAsyncAutoStartTimerAction()
        : StopAsyncAutoStartTimerAction());
  }

  Future<void> _showTimePicker() async {
    TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child,
        );
      },
    );
    if (time != null) {
      var dateNowToLocal = DateTime.now().toLocal();
      var sunrise = store.state.timesState.sunrise;
      var sunset = store.state.timesState.sunset;
      var moment = DateTime(
        dateNowToLocal.year,
        dateNowToLocal.month,
        dateNowToLocal.day,
        time.hour,
        time.minute,
      );
      var isAtOrAfterSunrise =
          moment.isAtSameMomentAs(sunrise) || moment.isAfter(sunrise);
      var isAtOrBeforeSunset =
          moment.isAtSameMomentAs(sunset) || moment.isBefore(sunset);
      if (isAtOrAfterSunrise && isAtOrBeforeSunset) {
        setState(() {
          _time = time;
          _timeAsString =
              '${time.hour > 12 ? time.hour - 12 : time.hour}:${time.minute < 10 ? '0${time.minute}' : time.minute} ${time.period == DayPeriod.am ? 'am' : 'pm'}';
        });
        store.dispatch(SetAutoStartValuesAction(
          autoStart: true,
          autoStartAtSunrise: store.state.rPiState.autoStartAtSunrise,
          autoStartTime: time,
          autoStartTimeAsString: _timeAsString,
        ));
      } else {
        await _displaySelectTimeWithinTwilightAlert();
        setState(() {
          _time = null;
          _timeAsString = null;
        });
        store.dispatch(SetAutoStartValuesAction(
          autoStart: store.state.rPiState.autoStart,
          autoStartAtSunrise: false,
          autoStartTime: null,
          autoStartTimeAsString: '',
        ));
      }
    }

    // if selected time is not within the twilight range,
    // than display an error message
    // update store state autoStart as false, autoStartAtSunrise as false, autoStartTime as null

    // if selected time is within the twilight range,
    // than set _time state
    // update Store state as autoStart true, autoStartAtSunrise as false, autoStartTime as time
  }

  Future<void> _displaySelectTimeWithinTwilightAlert() async {
    final sunrise = TimeOfDay(
      hour: store.state.timesState.sunrise.hour,
      minute: store.state.timesState.sunrise.minute,
    );
    final sunset = TimeOfDay(
      hour: store.state.timesState.sunset.hour,
      minute: store.state.timesState.sunset.minute,
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid Time'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('The time selected is not within twilight.'),
                Text(
                    'Choose a time between ${sunrise.hour}:${sunrise.minute}am and ${sunset.hour > 12 ? sunset.hour - 12 : sunset.hour}:${sunset.minute}pm'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    String timeAsString;
    if (store.state.rPiState.autoStartTime is TimeOfDay) {
      final t = store.state.rPiState.autoStartTime;
      timeAsString =
          '${t.hour > 12 ? t.hour - 12 : t.hour}:${t.minute} ${t.period == DayPeriod.am ? 'am' : 'pm'}';
    }

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        DateTime sunriseFromState = state.timesState.sunrise;
        String sunrise;
        if (sunriseFromState != null) {
          sunrise =
              '${sunriseFromState.hour}:${sunriseFromState.minute < 10 ? 0 : ''}${sunriseFromState.minute}am';
        }

        return OrientationBuilder(
          builder: (context, orientation) {
            return Scaffold(
              appBar: SignedInAppBar(
                title: 'Auto Start',
                automaticallyImplyLeading: true,
              ),
              body: Container(
                width: size.width,
                height: size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Auto Start Script',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: store.state.rPiState.autoStart,
                                    onChanged: (bool value) {
                                      _handleAutoStartOnChange(value);
                                    },
                                  ),
                                ],
                              ),
                              Divider(color: Colors.black12),
                              IgnorePointer(
                                ignoring: !store.state.rPiState.autoStart,
                                child: Opacity(
                                  opacity:
                                      store.state.rPiState.autoStart ? 1 : 0.5,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              // Shouldn't ever be null though in case, a nice display is displayed
                                              'Start at sunrise ',
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              '${sunrise != null ? '$sunrise' : ''}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value:
                                            state.rPiState.autoStartAtSunrise,
                                        onChanged: (bool value) {
                                          _handleAutoStartAtSunriseOnChange(
                                              value);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(color: Colors.black12),
                              IgnorePointer(
                                ignoring:
                                    store.state.rPiState.autoStartAtSunrise,
                                child: Opacity(
                                  // if start at sunrise selected than it's opaque
                                  opacity: _autoStartAtSunrise ? 0.5 : 1,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await _showTimePicker();
                                          },
                                          child: TitleValue(
                                              'Choose Time',
                                              store
                                                      .state
                                                      .rPiState
                                                      .autoStartTimeAsString
                                                      .isEmpty
                                                  ? 'Pick a time to auto-start'
                                                  : store.state.rPiState
                                                      .autoStartTimeAsString),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(color: Colors.black12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
