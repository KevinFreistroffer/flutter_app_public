import 'package:redux/redux.dart';
import 'models/app_state.dart';
import 'reducers/app_reducer.dart';

final store = Store<AppState>(
  appReducer,
  initialState: AppState.initial(),
);
