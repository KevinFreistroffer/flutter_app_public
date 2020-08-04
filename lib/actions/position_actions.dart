import 'package:flutter/material.dart';

class SetCoordinatesAction {
  final double latitude;
  final double longitude;

  SetCoordinatesAction({@required this.latitude, @required this.longitude});

  @override
  toString() {
    return 'SetCoordinatesAction{latitude: $latitude, longitude: $longitude}';
  }
}
