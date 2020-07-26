import 'package:flutter/material.dart';

class SetTimesAction {
  final DateTime sunrise;
  final DateTime sunset;
  final int dayLength;

  SetTimesAction({
    @required this.sunrise,
    @required this.sunset,
    @required this.dayLength,
  });

  @override
  String toString() {
    return 'SetTimesAction{ sunrise: $sunrise, sunset: $sunset, dayLength: $dayLength }';
  }
}
