import '../actions/solar_actions.dart';
import '../state/solar_state.dart';

SolarState solarReducer(SolarState state, dynamic action) {
  if (action is SetSolarValuesAction) {
    return state.copyWith(
      azimuth: action.azimuth,
      altitude: action.altitude,
      magneticDeclination: action.magneticDeclination,
    );
  }

  return state;
}
