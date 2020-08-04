import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geomag/geomag.dart';
import 'package:sunrise_sunset/sunrise_sunset.dart';
import 'package:flutter_suncalc/flutter_suncalc.dart';
import 'package:geolocator/geolocator.dart' as geoloc;
import 'package:location_platform_interface/location_platform_interface.dart';
// import 'package:spa/spa.dart';
//import 'coordinates.dart';
import '../constants.dart';

class SunTracking {
  geoloc.Position _position;
  double _latitude;
  double _longitude;
  double _magneticDeclination;
  String _hemisphere;
  DateTime _sunrise;
  DateTime _sunset;
  int _lengthOfDay;
  num _azimuth;
  num _altitude;
  Map<String, dynamic> _unitsOfTime;

  SunTracking() {}

  Future<void> getCurrentPosition() async {
    try {
      final geoloc.Geolocator geolocator = geoloc.Geolocator()
        ..forceAndroidLocationManager;
      geoloc.Position position = await geoloc.Geolocator().getCurrentPosition(
        desiredAccuracy: geoloc.LocationAccuracy.high,
      );

      _latitude = _position.latitude;
      _longitude = _position.longitude;

      _hemisphere = _latitude > 0
          ? Constants.HEMISPHERE_NORTHERN
          : Constants.HEMISPHERE_SOUTHERN;
    } catch (error) {
      print('An error occurred in geolocator.getCurrentPosition() $error');
    }
  }

  Future<void> setSunriseAndSunSet() async {
    try {
      final response = await SunriseSunset.getResults(
        date: DateTime.now(),
        latitude: _latitude,
        longitude: _longitude,
      );

      if (response.success) {
        _sunrise = response.data.sunrise;
        _sunset = response.data.sunset;
      }
    } catch (error) {
      print('An error occurred in SunRiseSunset.getResults() $error');
    }
  }

  Future<void> SetSolarValuesAction() async {
    // var output = spaCalculate(SPAParams(
    //   time: DateTime.now(),
    //   longitude: _longitude,
    //   latitude: _latitude,
    //   elevation:
    // ));
  }

  void setUnitsOfTimeValues() {
    final DateTime now = DateTime.now();
    final int millisecondsSinceEpoch = now.millisecondsSinceEpoch;

    _unitsOfTime = {
      'milliseconds': millisecondsSinceEpoch,
      'seconds': millisecondsSinceEpoch / 1000,
      'minutes': millisecondsSinceEpoch / 1000 / 60,
      'hours': millisecondsSinceEpoch / 1000 / 60 / 60,
    };
  }

  void setMagneticDeclination() {
    final GeoMag geoMag = GeoMag();
    final GeoMagResult result = geoMag.calculate(_latitude, _longitude);
    _magneticDeclination = result.dec;
  }

  double get latitude => _latitude;
  double get longitude => _longitude;
  double get magneticDeclination => _magneticDeclination;
  DateTime get sunrise => _sunrise;
  DateTime get sunset => _sunset;
  String get hemisphere => _hemisphere;
  num get azimuth => _azimuth;
  num get altitude => _altitude;
  Map<String, int> get unitsOfTime => _unitsOfTime;
}

// Future<void> run() async {
//   try {
//     // apparently the declination angle is
//     // -0.39873441499985341918727445241527
//     final Position position = await getCurrentLocation();
//     final GeoMag geoMag = GeoMag();
//     final GeoMagResult result =
//         geoMag.calculate(position.latitude, position.longitude);
//     final double dec = result.dec;

//     // Something about a compass or using a 360 degree servo, tell the user to point the center of the servo decl somehow east or west degrees
//     // use a compass or use a built in compass app somehow or guess and adjust decl degrees or do whatever the fuck you want.
//     // from true north or true south based on the address provided

//     // if hemisphere is northern, tell the user to face the panel south.
//     // if decl is a positive number, tell them to turn it east decl degrees
//     // else if decl is a negative number, tell them to turn it west decl degrees

//     // if hemisphere is southern, tell the user to face the panel north.
//     // if decl is a positive number, tell them to turn it west decl degrees
//     // if decl is a negative number, tell them to turn it east decl degrees

//     if (position.latitude != null && position.longitude != null) {
//       final timer = Timer(Duration(seconds: 1), () {
//         final DateTime now = DateTime.now();
//         final int millisecondsSinceEpoch = now.millisecondsSinceEpoch;

//         final Map _unitsOfTime = {
//           'milliseconds': millisecondsSinceEpoch,
//           'seconds': millisecondsSinceEpoch / 1000,
//           'minutes': millisecondsSinceEpoch / 1000 / 60,
//           'hours': millisecondsSinceEpoch / 1000 / 60 / 60,
//         };

//         final sunrisePos = SunCalc.getPosition(
//           now,
//           position.latitude,
//           position.longitude,
//         );
//         print(sunrisePos);
//         //print(azimuth, altitude);

//         // Calculate now minus sunrise
//         // multiply tiltData by the above calculation
//         //console.log(nowData.milliseconds - times.sunrise);
//         // so every minute angle it this much.fail

//         // its been this many minutes since sunrise, so multiply that many minutes by tiltData.minutes
//         // I start the app, and there is 8 hours left in the day.
//         // So it would rotate to the right the degrees of the sunrise to the sunset
//         // divided by the 8 hours as seconds, and the tilt is determined by the azimuth and altitude every
//         // second.
//       });
//     }
//   } catch (error) {
//     // errorHandler(error);
//   }
// }
