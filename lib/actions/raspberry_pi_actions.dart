import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter_keto/store.dart';

class SetSSHStatusAction {
  final String sshStatus;

  SetSSHStatusAction({@required this.sshStatus});
}

class SetScriptStatusAction {
  final bool scriptRunning;

  SetScriptStatusAction({@required this.scriptRunning});
}

class SetAutoStartValuesAction {
  final bool autoStart;
  final bool autoStartAtSunrise;
  final TimeOfDay autoStartTime;
  final String autoStartTimeAsString;

  SetAutoStartValuesAction({
    @required this.autoStart,
    @required this.autoStartAtSunrise,
    @required this.autoStartTime,
    @required this.autoStartTimeAsString,
  });
}

class StartAsyncAutoStartTimerAction {
  StartAsyncAutoStartTimerAction();
}

class StopAsyncAutoStartTimerAction {
  StopAsyncAutoStartTimerAction();
}
