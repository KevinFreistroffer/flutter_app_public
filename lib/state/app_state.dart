import 'package:flutter/material.dart';
import 'package:flutter_keto/constants.dart';
import 'loading_state.dart';
import 'position_state.dart';
import 'solar_state.dart';
import 'times_state.dart';
import 'user_state.dart';
import 'raspberry_pi_state.dart';

class AppState {
  final LoadingState loadingState;
  final PositionState positionState;
  final SolarState solarState;
  final TimesState timesState;
  final UserState userState;
  final RPiState rPiState;

  AppState({
    @required this.loadingState,
    @required this.positionState,
    @required this.solarState,
    @required this.timesState,
    @required this.userState,
    @required this.rPiState,
  });

  factory AppState.initial() {
    return AppState(
      loadingState: LoadingState.initial(),
      positionState: PositionState.initial(),
      solarState: SolarState.initial(),
      timesState: TimesState.initial(),
      userState: UserState.initial(),
      rPiState: RPiState.initial(),
    );
  }

  AppState copyWith({
    LoadingState loadingState,
    PositionState positionState,
    SolarState solarState,
    TimesState timesState,
    UserState userState,
    RPiState rPiState,
  }) {
    return AppState(
      loadingState: loadingState ?? this.loadingState,
      positionState: positionState ?? this.positionState,
      solarState: solarState ?? this.solarState,
      timesState: timesState ?? this.timesState,
      userState: userState ?? this.userState,
      rPiState: rPiState ?? this.rPiState,
    );
  }
}
