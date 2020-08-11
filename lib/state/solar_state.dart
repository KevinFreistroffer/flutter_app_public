import 'package:meta/meta.dart';

@immutable
class SolarState {
  final double azimuth;
  final double zenith;
  final double magneticDeclination;

  SolarState({
    @required this.azimuth,
    @required this.zenith,
    @required this.magneticDeclination,
  });

  SolarState copyWith({
    @required azimuth,
    @required zenith,
    @required magneticDeclination,
  }) {
    return SolarState(
      azimuth: azimuth,
      zenith: zenith,
      magneticDeclination: magneticDeclination,
    );
  }

  factory SolarState.initial() {
    return SolarState(
      azimuth: null,
      zenith: null,
      magneticDeclination: null,
    );
  }

  @override
  String toString() {
    return 'Times{azimuth: $azimuth, magneticDeclination: $magneticDeclination, zenith: $zenith}';
  }
}
