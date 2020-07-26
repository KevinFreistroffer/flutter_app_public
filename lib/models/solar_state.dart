import 'package:meta/meta.dart';

@immutable
class SolarState {
  final double azimuth;
  final double altitude;

  SolarState({
    @required this.azimuth,
    @required this.altitude,
  });

  SolarState copyWith({
    @required azimuth,
    @required altitude,
  }) {
    return SolarState(
      azimuth: azimuth,
      altitude: altitude,
    );
  }

  factory SolarState.initial() {
    return SolarState(
      azimuth: null,
      altitude: null,
    );
  }

  @override
  String toString() {
    return 'Times{azimuth: $azimuth, altitude: $altitude}';
  }
}
