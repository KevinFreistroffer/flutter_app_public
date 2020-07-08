import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CoordinatesModel extends ChangeNotifier {
  double _latitude;
  double _longitude;

  UnmodifiableMapView get coordinates => UnmodifiableMapView(
        {
          'latitude': _latitude ?? '',
          'longitude': _longitude ?? '',
        },
      );

  double get latitude => _latitude;
  double get longitude => _longitude;

  void set({
    double latitude,
    double longitude,
  }) {
    print('coordinatesModel.set() $latitude, $longitude');
    _latitude = latitude ?? _latitude;
    _longitude = longitude ?? _longitude;

    notifyListeners();
  }

  void emptyAllValues() {
    _latitude = null;
    _latitude = null;
  }
}
