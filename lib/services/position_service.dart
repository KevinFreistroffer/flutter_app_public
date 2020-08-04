import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geomag/geomag.dart';
import 'package:location/location.dart' as loc;

class PositionService {
  double latitude;
  double longitude;

  Future<Position> getCurrentPosition() async {
    Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
    return await geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<double> getMagneticDeclination() async {
    final Position position = await getCurrentPosition();

    final geomag = GeoMag();
    final result = geomag.calculate(
      position.latitude,
      position.longitude,
    );

    print('geomag() result $result');

    return result.dec;
  }
}
