import 'package:redux/redux.dart';
import '../actions/position_actions.dart';
import '../models/position.dart';
import '../models/app_state.dart';

AppState positionReducer(AppState prevState, dynamic action) {
  AppState newState = AppState.fromAppState(prevState);

  if (action is SetCoordinatesAction) {
    newState.latitude = action.latitude;
    newState.longitude = action.longitude;

    return newState;
  } else {
    return newState;
  }
}
