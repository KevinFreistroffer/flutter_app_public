import 'dart:async';
import 'package:sunrise_sunset/sunrise_sunset.dart';

class TimesService {
  Future<dynamic> getSunriseAndSunset(double latitude, double longitude) {
    return SunriseSunset.getResults(
      date: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
    );
  }
}
