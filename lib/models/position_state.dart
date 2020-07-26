import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
class PositionState {
  final double latitude;
  final double longitude;

  PositionState({
    @required this.latitude,
    @required this.longitude,
  });

  PositionState copyWith({@required latitude, @required longitude}) {
    return PositionState(
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory PositionState.initial() {
    return PositionState(latitude: null, longitude: null);
  }
}
