import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_keto/services/position_service.dart';
import 'package:flutter_keto/state/app_state.dart';
import 'package:sunrise_sunset/sunrise_sunset.dart';
import 'package:flutter_redux/flutter_redux.dart';

class TimesService {
  Future<dynamic> getSunriseAndSunset(double latitude, double longitude) {
    return SunriseSunset.getResults(
      date: DateTime.now().toLocal(),
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<bool> isWithinTwilightHours({@required TimeOfDay time}) async {
    bool result = false;
    try {
      final PositionService _positionService = PositionService();
      final position = await _positionService.getCurrentPosition();

      print('position lat and long should not be null');
      print('position $position ${position.latitude}');

      var times =
          await getSunriseAndSunset(position.latitude, position.longitude);
      print('calling DateTime.now().toLocal() ${DateTime.now().toLocal()}');
      var now = DateTime.now().toLocal();
      var moment = DateTime(now.year, now.month, now.day, now.hour, now.minute);
      var isAtOrAfterSunrise = moment.isAtSameMomentAs(times.data.sunrise) ||
          moment.isAfter(times.data.sunrise);

      var isAtOrBeforeSunset = moment.isAtSameMomentAs(times.data.sunset) ||
          moment.isBefore(times.data.sunset);

      result = isAtOrAfterSunrise && isAtOrBeforeSunset;
    } catch (error) {
      print('An error occurred in isWithinTwilightHours() $error');
    }

    return result;
  }
}
