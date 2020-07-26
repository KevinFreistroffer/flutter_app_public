import 'dart:async';
import 'package:sunrise_sunset/sunrise_sunset.dart';

class TimesService {
  Future<dynamic> getSunriseAndSunset(double latitude, double longitude) {
    return SunriseSunset.getResults(
      date: DateTime(2020, 7, 24).toLocal(),
      latitude: latitude,
      longitude: longitude,
    );
  }
}
