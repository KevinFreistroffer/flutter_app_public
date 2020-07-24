import 'package:meta/meta.dart';
import './position.dart';

class AppState {
  double latitude;
  double longitude;

  AppState({this.latitude, this.longitude});

  AppState.fromAppState(AppState currentState) {
    latitude = currentState.latitude;
    longitude = currentState.longitude;
  }
}
