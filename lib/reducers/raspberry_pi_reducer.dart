import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_keto/constants.dart';
import 'package:flutter_keto/services/raspberrypi_service.dart';
import 'package:flutter_keto/services/times_service.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_keto/actions/raspberry_pi_actions.dart';
import 'package:flutter_keto/state/raspberry_pi_state.dart';
import 'package:flutter_keto/store.dart';

final raspberryPiReducer = combineReducers<RPiState>(
  [
    TypedReducer<RPiState, SetSSHStatusAction>(_setSSHStatus),
    TypedReducer<RPiState, SetScriptStatusAction>(_setScriptStatus),
    TypedReducer<RPiState, SetAutoStartValuesAction>(
      _setAutoStartValues,
    ),
    TypedReducer<RPiState, StartAsyncAutoStartTimerAction>(
      _startAsyncAutoStartTimer,
    ),
  ],
);

// TODO shouldn't have to set all the values, as not all properties are mutated in each action. How to make it so
// copyWith can only accept the key value of the property being changed?

RPiState _setSSHStatus(
  RPiState state,
  SetSSHStatusAction action,
) {
  return state.copyWith(
    sshStatus: action.sshStatus,
    autoStart: state.autoStart,
    autoStartAtSunrise: state.autoStartAtSunrise,
    scriptRunning: state.scriptRunning,
    autoStartTime: state.autoStartTime,
    autoStartTimeAsString: state.autoStartTimeAsString,
  );
}

RPiState _setScriptStatus(
  RPiState state,
  SetScriptStatusAction action,
) {
  return state.copyWith(
    sshStatus: state.sshStatus,
    autoStart: state.autoStart,
    autoStartAtSunrise: state.autoStartAtSunrise,
    scriptRunning: action.scriptRunning,
    autoStartTime: state.autoStartTime,
    autoStartTimeAsString: state.autoStartTimeAsString,
  );
}

RPiState _setAutoStartValues(
  RPiState state,
  SetAutoStartValuesAction action,
) =>
    state.copyWith(
      sshStatus: state.sshStatus,
      autoStart: action.autoStart,
      autoStartAtSunrise: action.autoStartAtSunrise,
      scriptRunning: state.scriptRunning,
      autoStartTime: action.autoStartTime,
      autoStartTimeAsString: action.autoStartTimeAsString,
    );

RPiState _startAsyncAutoStartTimer(
  RPiState state,
  StartAsyncAutoStartTimerAction action,
) {
  return state.copyWith(
    sshStatus: state.sshStatus,
    autoStart: state.autoStart,
    autoStartAtSunrise: state.autoStartAtSunrise,
    scriptRunning: state.scriptRunning,
    autoStartTime: state.autoStartTime,
    autoStartTimeAsString: state.autoStartTimeAsString,
  );
}

RPiState _stopAsyncAutoStartTimer(
  RPiState state,
  StopAsyncAutoStartTimerAction action,
) {
  return state.copyWith(
    sshStatus: state.sshStatus,
    autoStart: state.autoStart,
    autoStartAtSunrise: state.autoStartAtSunrise,
    scriptRunning: state.scriptRunning,
    autoStartTime: state.autoStartTime,
    autoStartTimeAsString: state.autoStartTimeAsString,
  );
}
