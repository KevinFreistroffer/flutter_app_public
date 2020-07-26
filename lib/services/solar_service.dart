import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_suncalc/flutter_suncalc.dart';
import 'position_service.dart';
import '../store.dart';
import '../actions/solar_actions.dart';

class SolarService {
  PositionService _positionService = PositionService();
  double eastAngle = 90;
  double westAngle = 270;

  // 180 degrees
  // on the summer solstice, the sun will rise 110degrees east of due south. So then on June 21st, the
  // servo start value is 0, and the end value is 180.
  // the number of hours is say 12 hours.
  // 180 / 12 = 15 degrees an hour
  // 15 / 60 = .25 degrees a minute
  // .25 / 60 = 0.00416 degrees a second.

  // So then, when it's 20 days since the summer solstice, what is the azimuth of the sunrise? What is the difference from the summer
  // solstice 180 or 0 degree angle? How much does it shift from 180 or 0 day by day?

  Future<Map> getAzimuthAndAltitude() async {
    print('getAzimuth()');
    print(store.state.toString());
    var sunCalcPosition = SunCalc.getPosition(
      store.state.sunrise,
      store.state.latitude,
      store.state.longitude,
    );

    print('sunCalcPosition $sunCalcPosition');
    print('sunCalcPosition azimuth ${sunCalcPosition['azimuth']}');

    return {
      'azimuth': sunCalcPosition['azimuth'] * 180 / PI,
      'altitude': sunCalcPosition['altitude'],
    };
  }
}

// class SolarService {
//   double fractionalYear;
//   double eqtime;
//   double decl;
//   var timeOffset;
//   var trueSolarTime;
//   var solarHourAngle;
//   var solarZenithAngle;
//   var solarAzimuth;

//   SolarService();

//   getFractionalYear() {
//     var now = DateTime.now();
//     var dayOfTheYear = int.parse(DateFormat('D').format(now));
//     fractionalYear =
//         ((math.pi * 2) / 365) * (dayOfTheYear - 1 + ((now.hour - 12) / 24));
//   }

//   getEQTime() {
//     var a = 229.18; // *
//     var b = 0.000075 + (0.001868 * math.cos(fractionalYear)); // -
//     var c = 0.032077 * math.sin(fractionalYear); // -
//     var d = 0.014615 * math.cos(2 * fractionalYear); // -
//     var e = 0.040849 * math.sin(2 * fractionalYear); // =
//     eqtime = a * (b - c - d - e);

//     print('eqTime $eqtime');
//   }

//   getDecl() {
//     var a = 0.006918; // -
//     var b = 0.399912 * math.cos(fractionalYear); // +
//     var c = 0.070257 * math.sin(fractionalYear); // -
//     var d = 0.006758 * math.cos(2 * fractionalYear); // +
//     var e = 0.000907 * math.sin(2 * fractionalYear); // -
//     var f = 0.002697 * math.cos(3 * fractionalYear); // +
//     var g = 0.00148 * math.sin(3 * fractionalYear);
//     decl = a - b + c - d + e - f + g;
//     print('decl $decl');
//   }

//   getTimeOffset() {
//     var longitude = -120.1856314;
//     timeOffset = eqtime + (4 * -120.1856314) - (60 * -7);
//     print('timeOffset $timeOffset');
//   }

//   getTrueSolarTime() {
//     var hr = DateTime.now().hour;
//     var mn = DateTime.now().minute;
//     var sc = DateTime.now().second;

//     trueSolarTime = (hr * 60) + mn + (sc / 60) + timeOffset;
//     print('trueSolarTime $trueSolarTime');
//   }

//   getSolarHourAngle() {
//     solarHourAngle = (trueSolarTime / 4) - 180;
//     print('solarHourAngle $solarHourAngle');
//   }

//   getSolarZenithAngle() {
//     var lat = 39.3390735;
//     solarZenithAngle = math.cos(math.sin(lat) * math.sin(decl) +
//         math.cos(lat) * math.cos(decl) * math.cos(solarHourAngle));

//     print('solarZenithAngle $solarZenithAngle');
//   }
// }
