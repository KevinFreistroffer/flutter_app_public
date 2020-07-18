import 'dart:async';
import 'package:geolocator/geolocator.dart';

class PositionService {
  double latitude;
  double longitude;

  Future<Position> getCurrentPosition() async {
    Position position;

    try {
      Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
      position = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (error) {
      print('An error occurred in geolocator.getCurrentPosition $error');
    }

    return position;
  }
}
