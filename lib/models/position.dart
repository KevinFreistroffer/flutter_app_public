import 'package:meta/meta.dart';

@immutable
class Position {
  final double latitude;
  final double longitude;

  Position(this.latitude, this.longitude);

  // Position copyWith(double latitude, double longitude) {
  //   return Position(latitude, longitude);
  // }

  // @override
  // int get hashCode => latitude.hashCode ^ longitude.hashCode;

  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //     other is Position &&
  //         runtimeType == other.runtimeType &&
  //         latitude == other.latitude &&
  //         longitude == other.longitude;

  @override
  String toString() {
    return 'Position{latitude: $latitude, longitude: $longitude}';
  }
}
