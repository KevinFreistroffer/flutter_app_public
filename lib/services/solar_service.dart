import 'package:flutter_suncalc/flutter_suncalc.dart';
import 'package:spa/spa.dart';
import 'package:geomag/geomag.dart';
import 'package:flutter_keto/store.dart';
import 'package:flutter_keto/actions/solar_actions.dart';
import './times_service.dart';
import './position_service.dart';

class SolarService {
  double eastAngle = 90;
  double westAngle = 270;
  double magneticDeclination = 0;
  var num = .328;

  int getDaysSinceSummerSolstice() {
    var now = DateTime.now();
    var summerSolstice = DateTime(now.year, 6, 21);
    var diff = now.difference(summerSolstice);
    return diff.inDays;
  }

  Future<void> calculateSolarAngle() async {
    final position = await PositionService().getCurrentPosition();
    final times = await TimesService()
        .getSunriseAndSunset(position.latitude, position.longitude);
    var range = 180 - ((getDaysSinceSummerSolstice() * .328) * 2);
    var now = DateTime.now().toLocal();

    var sunrise = DateTime(
      now.year,
      now.month,
      now.day,
      times.data.sunrise.toLocal().hour,
      times.data.sunrise.toLocal().minute,
      times.data.sunrise.toLocal().second,
    );
    var timeSinceSunrise = now.difference(sunrise);

    var dayLength = times.data.dayLength;
    var percentageOfTwilightCompleted = timeSinceSunrise.inSeconds / dayLength;

    final geomag = GeoMag();
    final geomagResult =
        geomag.calculate(position.latitude, position.longitude);

    print('geomagResult $geomagResult');
  }

  Future<Map> getSolarValues() async {
    var longitude = store.state.positionState.longitude;
    var latitude = store.state.positionState.latitude;

    var spaResult = spaCalculate(
      SPAParams(
        time: DateTime.now().toLocal(),
        latitude: latitude,
        longitude: longitude,
      ),
    );

    print('spaResult.zenith ${spaResult.zenith}');

    return {'azimuth': spaResult.azimuth, 'zenith': spaResult.zenith};
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
