import 'package:redux/redux.dart';
import '../models/position.dart';
import '../models/app_state.dart';
import 'position_reducer.dart';

final rootReducer = combineReducers<AppState>([positionReducer]);
