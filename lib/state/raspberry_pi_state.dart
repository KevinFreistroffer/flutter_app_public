import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:flutter_keto/constants.dart';

@immutable
class RPiState {
  final String sshStatus;
  final bool autoStart;
  final bool autoStartAtSunrise;
  final bool scriptRunning;
  final TimeOfDay autoStartTime;
  final String autoStartTimeAsString;

  RPiState({
    @required this.sshStatus,
    @required this.autoStart,
    @required this.autoStartAtSunrise,
    @required this.scriptRunning,
    @required this.autoStartTime,
    @required this.autoStartTimeAsString,
  });

  RPiState copyWith({
    String sshStatus,
    bool autoStart,
    bool autoStartAtSunrise,
    bool scriptRunning,
    TimeOfDay autoStartTime,
    String autoStartTimeAsString,
  }) {
    return RPiState(
      sshStatus: sshStatus,
      autoStart: autoStart,
      autoStartAtSunrise: autoStartAtSunrise,
      scriptRunning: scriptRunning,
      autoStartTime: autoStartTime,
      autoStartTimeAsString: autoStartTimeAsString,
    );
  }

  @override
  toString() {
    var str = '';

    str += 'RPiState \n';
    str += '{ sshStatus: $sshStatus, \n';
    str += '{ autoStart: $autoStart, \n';
    str += '{ autoStartAtSunrise: $autoStartAtSunrise, \n';
    str += '{ autoStartTime: $autoStartTime, \n';
    str += '{ autoStartTimeAsString: $autoStartTimeAsString, \n';
    str += '{ scriptRunning: $scriptRunning, \n';
    str += ' }';

    return str;
  }

  factory RPiState.initial() {
    return RPiState(
      sshStatus: Constants.SSH_DISCONNECTED,
      autoStart: false,
      autoStartAtSunrise: false,
      autoStartTime: null,
      autoStartTimeAsString: '',
      scriptRunning: false,
    );
  }
}
