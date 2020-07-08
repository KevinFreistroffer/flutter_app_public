import 'dart:math' as math;
import 'package:intl/intl.dart';

class SolarService {
  double fractionalYear;
  double eqtime;
  double decl;
  var timeOffset;
  var trueSolarTime;
  var solarHourAngle;
  var solarZenithAngle;
  var solarAzimuth;

  SolarService();

  getFractionalYear() {
    var now = DateTime.now();
    var dayOfTheYear = int.parse(DateFormat('D').format(now));
    fractionalYear =
        ((math.pi * 2) / 365) * (dayOfTheYear - 1 + ((now.hour - 12) / 24));
  }

  getEQTime() {
    var a = 229.18; // *
    var b = 0.000075 + (0.001868 * math.cos(fractionalYear)); // -
    var c = 0.032077 * math.sin(fractionalYear); // -
    var d = 0.014615 * math.cos(2 * fractionalYear); // -
    var e = 0.040849 * math.sin(2 * fractionalYear); // =
    eqtime = a * (b - c - d - e);

    print('eqTime $eqtime');
  }

  getDecl() {
    var a = 0.006918; // -
    var b = 0.399912 * math.cos(fractionalYear); // +
    var c = 0.070257 * math.sin(fractionalYear); // -
    var d = 0.006758 * math.cos(2 * fractionalYear); // +
    var e = 0.000907 * math.sin(2 * fractionalYear); // -
    var f = 0.002697 * math.cos(3 * fractionalYear); // +
    var g = 0.00148 * math.sin(3 * fractionalYear);
    decl = a - b + c - d + e - f + g;
    print('decl $decl');
  }

  getTimeOffset() {
    var longitude = -120.1856314;
    timeOffset = eqtime + (4 * -120.1856314) - (60 * -7);
    print('timeOffset $timeOffset');
  }

  getTrueSolarTime() {
    var hr = DateTime.now().hour;
    var mn = DateTime.now().minute;
    var sc = DateTime.now().second;

    trueSolarTime = (hr * 60) + mn + (sc / 60) + timeOffset;
    print('trueSolarTime $trueSolarTime');
  }

  getSolarHourAngle() {
    solarHourAngle = (trueSolarTime / 4) - 180;
    print('solarHourAngle $solarHourAngle');
  }

  getSolarZenithAngle() {
    var lat = 39.3390735;
    solarZenithAngle = math.cos(math.sin(lat) * math.sin(decl) +
        math.cos(lat) * math.cos(decl) * math.cos(solarHourAngle));

    print('solarZenithAngle $solarZenithAngle');
  }
}
