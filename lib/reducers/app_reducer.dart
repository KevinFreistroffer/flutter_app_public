import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../reducers/loading_reducer.dart';
import '../reducers/position_reducer.dart';
import '../reducers/solar_reducer.dart';
import '../reducers/times_reducer.dart';

AppState appReducer(AppState state, dynamic action) => new AppState(
      loadingState: loadingReducer(state.loadingState, action),
      positionState: positionReducer(state.positionState, action),
      solarState: solarReducer(state.solarState, action),
      timesState: timesReducer(state.timesState, action),
    );
