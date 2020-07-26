import 'package:redux/redux.dart';
import '../actions/times_actions.dart';
import '../models/times_state.dart';

final timesReducer = combineReducers<TimesState>(
  [TypedReducer<TimesState, SetTimesAction>(_setTimes)],
);

TimesState _setTimes(TimesState state, SetTimesAction action) {
  return state.copyWith(
    sunrise: action.sunrise,
    sunset: action.sunset,
    dayLength: action.dayLength,
  );
}
