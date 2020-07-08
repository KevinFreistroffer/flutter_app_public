import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:sunrise_sunset/sunrise_sunset.dart';
import 'coordinates.dart';

Future<void> times() async {
  var response;
  final Position position = await getCurrentLocation();

  try {
    if (position.longitude != null && position.latitude != null) {
      final results = await SunriseSunset.getResults(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      response = {
        'sunrise': results.data.sunrise,
        'sunset': results.data.sunset,
      };
    }
  } catch (error) {
    print('An error occurred calling getCurrentLocation() $error');
    response = error.toString();
  }

  return response;
}
