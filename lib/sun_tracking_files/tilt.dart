import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'coordinates.dart';

Future<Map> getTilt() async {
  var response;
  try {
    final Position position = await getCurrentLocation();
    if (position is Position) {
      // success
      double latitude = position.latitude;
      double longitude = position.longitude;
      var azimuth;
      var altitude;
      var sunrise;
      var sunset;
      var totalTilt = 180;
      DateTime january1st = DateTime(2020, 1, 1);
      final now = DateTime.now();
      final numOfDaysSinceJanuary1st = now.difference(january1st).inDays;
      //Cosine(asimuth) = (Sine(sunsDeclination) / Cosine(latitude))

      var a = numOfDaysSinceJanuary1st + 10;
      var b = 360 / 365;
      var c = a * b;
      var d = cos(c) * -23.44;
      // I think this means, that, as of writing this at 12:17pm, the value is 4.4,
      // so the tilt angle is 4 degrees, pretty muxch
      var sunsAzimuth = sin(d) / cos(latitude);

      print('sunsAzimuth $sunsAzimuth');

      Map dayData = {
        'milliseconds': sunset - sunrise,
        'seconds': (sunset - sunrise) / 1000,
        'minutes': (sunset - sunrise) / 1000 / 60,
        'hours': (sunset - sunrise) / 1000 / 60 / 60,
      };

      response = {
        'milliseconds': 180 / dayData['milliseconds'],
        'seconds': 180 / dayData['seconds'],
        'minutes': 180 / dayData['minutes'],
        'hours': 180 / dayData['hours'],
      };
    }
  } catch (error) {
    print('An error occurred in getTilt calling getCurrentLocation() $error');
    response = error.toString();
  }

  return response;
}
