import 'dart:async';
import 'package:sunrise_sunset/sunrise_sunset.dart';

class TimesService {
  Future<dynamic> getSunriseAndSunset(double latitude, double longitude) {
    return SunriseSunset.getResults(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
