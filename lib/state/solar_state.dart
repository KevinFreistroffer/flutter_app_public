import 'package:meta/meta.dart';

@immutable
class SolarState {
  final double azimuth;
  final double altitude;
  final double magneticDeclination;

  SolarState({
    @required this.azimuth,
    @required this.altitude,
    @required this.magneticDeclination,
  });

  SolarState copyWith({
    @required azimuth,
    @required altitude,
    @required magneticDeclination,
  }) {
    return SolarState(
      azimuth: azimuth,
      altitude: altitude,
      magneticDeclination: magneticDeclination,
    );
  }

  factory SolarState.initial() {
    return SolarState(
      azimuth: null,
      altitude: null,
      magneticDeclination: null,
    );
  }

  @override
  String toString() {
    return 'Times{azimuth: $azimuth, altitude: $altitude, magneticDeclination: $magneticDeclination}';
  }
}
