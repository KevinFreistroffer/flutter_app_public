import 'dart:async';
import 'package:flutter_keto/actions/raspberry_pi_actions.dart';
import 'package:flutter_keto/services/times_service.dart';
import 'package:flutter_keto/services/raspberrypi_service.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'state/app_state.dart';
import 'reducers/app_reducer.dart';
import 'package:flutter_keto/constants.dart';

final store = Store(
  appReducer,
  middleware: [
    thunkMiddleware,
    AutoStartMiddleware(),
  ],
  initialState: AppState.initial(),
);

class AutoStartMiddleware implements MiddlewareClass<AppState> {
  final TimesService _timesService = TimesService();
  final RPiService _RPiService = RPiService();
  Timer _timer;

  AutoStartMiddleware();

  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    print('AutoStartMiddleware() call()');
    print('action $action');

    if (action is StartAsyncAutoStartTimerAction) {
      print('AutoStartMiddleware() call() is StartAsyncAction');

      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        // Handles if the script is started automatically
        // and cancels the timer to prevent recalling startScript repeatedly

        var now = DateTime.now().toLocal();
        bool isWithinTwilightHours = await _timesService.isWithinTwilightHours(
          time: store.state.rPiState.autoStartTime,
        );

        if (isWithinTwilightHours) {
          try {
            var state = store.state;

            var sunriseDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              state.timesState.sunrise.toLocal().hour,
              state.timesState.sunrise.toLocal().minute,
            );

            var sunsetDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              state.timesState.sunset.toLocal().hour,
              state.timesState.sunset.toLocal().minute,
            );

            Duration duration = sunsetDateTime.difference(sunriseDateTime);
            Duration durationSinceSunrise =
                DateTime.now().toLocal().difference(sunriseDateTime);

            store.dispatch(SetScriptStatusAction(scriptRunning: true));

            final scriptResponse = await _RPiService.startScript(
              twilightDuration: duration.inMinutes,
              minutesSinceSunrise: durationSinceSunrise.inMinutes,
            );

            // Successfully completed the script
            if (scriptResponse == Constants.SCRIPT_COMPLETED) {
              store.dispatch(SetScriptStatusAction(scriptRunning: false));
            }
          } catch (error) {
            print('An error occurred in startScript() $error');
            store.dispatch(SetScriptStatusAction(scriptRunning: false));
          }
        } else {
          //SetSolarValuesAction_displayWaitUntilSunriseMessage();
        }
      });
    }

    if (action is StopAsyncAutoStartTimerAction) {
      print('AutoStartMiddleware() call() is StopAsyncAction');

      _timer.cancel();
    }

    next(action);
  }
}
