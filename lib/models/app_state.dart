import 'package:flutter/material.dart';
import 'loading_state.dart';
import 'position_state.dart';
import 'solar_state.dart';
import 'times_state.dart';

class AppState {
  final LoadingState loadingState;
  final PositionState positionState;
  final SolarState solarState;
  final TimesState timesState;

  double latitude;
  double longitude;
  DateTime sunrise;
  DateTime sunset;
  int dayLength;
  double azimuth;
  double altitude;

  AppState({
    @required this.loadingState,
    @required this.positionState,
    @required this.solarState,
    @required this.timesState,
    this.latitude,
    this.longitude,
    this.sunrise,
    this.sunset,
    this.dayLength,
    this.azimuth,
    this.altitude,
  });

  factory AppState.initial() {
    return AppState(
      loadingState: LoadingState.initial(),
      positionState: PositionState.initial(),
      solarState: SolarState.initial(),
      timesState: TimesState.initial(),
      latitude: null,
      longitude: null,
      sunrise: null,
      sunset: null,
      dayLength: null,
      azimuth: null,
      altitude: null,
    );
  }

  AppState copyWith({
    LoadingState loadingState,
    PositionState positionState,
    SolarState solarState,
    TimesState timesState,
  }) {
    return AppState(
      loadingState: loadingState ?? this.loadingState,
      positionState: positionState ?? this.positionState,
      solarState: solarState ?? this.solarState,
      timesState: timesState ?? this.timesState,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      dayLength: dayLength ?? this.dayLength,
      azimuth: azimuth ?? this.azimuth,
      altitude: altitude ?? this.altitude,
    );
  }

  @override
  String toString() {
    var str = '';
    str += 'AppState{ ';
    str += 'latitude: $latitude, \n';
    str += 'longitude: $longitude, \n';
    str += 'sunrise: $sunrise, \n';
    str += 'sunset: $sunset, \n';
    str += 'dayLength: $dayLength, \n';
    str += 'azimuth: $azimuth, \n';
    str += 'altitude: $altitude, \n';
    // loading.forEach((key, value) {
    //   str += '$key: $value, \n';
    // });
    str += '}';
    return str;
  }
}
