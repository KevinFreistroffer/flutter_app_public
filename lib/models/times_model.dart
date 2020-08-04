import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class TimesModel extends ChangeNotifier {
  String _sunrise;
  String _sunset;
  int _dayLength;

  UnmodifiableMapView get times => UnmodifiableMapView(
        {
          'sunrise': _sunrise ?? '',
          'sunset': _sunset ?? '',
          'dayLength': _dayLength ?? null,
        },
      );

  String get sunrise => _sunrise;
  String get sunset => _sunset;
  int get dayLength => _dayLength;

  void set({
    String sunrise,
    String sunset,
    int dayLength,
  }) {
    _sunrise = sunrise ?? _sunrise;
    _sunset = sunset ?? _sunset;
    _dayLength = dayLength ?? _dayLength;

    notifyListeners();
  }

  void emptyAllValues() {
    _sunrise = '';
    _sunset = '';
    _dayLength = null;
  }
}
