import 'package:redux/redux.dart';
import '../actions/position_actions.dart';
import '../models/position_state.dart';
import '../models/position_state.dart';

PositionState positionReducer(PositionState state, dynamic action) {
  if (action is SetCoordinatesAction) {
    return state.copyWith(
      latitude: action.latitude,
      longitude: action.longitude,
    );
  } else {
    return state;
  }
}
