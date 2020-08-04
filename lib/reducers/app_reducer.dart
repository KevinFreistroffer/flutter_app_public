import 'package:flutter/material.dart';
import 'package:flutter_keto/state/app_state.dart';
import 'package:flutter_keto/reducers/loading_reducer.dart';
import 'package:flutter_keto/reducers/position_reducer.dart';
import 'package:flutter_keto/reducers/solar_reducer.dart';
import 'package:flutter_keto/reducers/times_reducer.dart';
import 'package:flutter_keto/reducers/user_reducer.dart';
import 'package:flutter_keto/reducers/raspberry_pi_reducer.dart';

AppState appReducer(AppState state, dynamic action) => new AppState(
      loadingState: loadingReducer(state.loadingState, action),
      positionState: positionReducer(state.positionState, action),
      solarState: solarReducer(state.solarState, action),
      timesState: timesReducer(state.timesState, action),
      userState: userReducer(state.userState, action),
      rPiState: raspberryPiReducer(state.rPiState, action),
    );
