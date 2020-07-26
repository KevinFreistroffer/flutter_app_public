import '../actions/solar_actions.dart';
import '../models/solar_state.dart';

SolarState solarReducer(SolarState state, dynamic action) {
  if (action is SetAzimuthAndAltitudeAction) {
    return state.copyWith(
      azimuth: action.azimuth,
      altitude: action.altitude,
    );
  }

  return state;
}
