import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> getCurrentLocation() async {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  return geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );
}
