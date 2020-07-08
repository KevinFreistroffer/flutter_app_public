import 'dart:async';
import 'package:geolocator/geolocator.dart';

class PositionService {
  double latitude;
  double longitude;

  Future<Position> getCurrentPosition() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    return geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
