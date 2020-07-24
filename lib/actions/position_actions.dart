enum PositionActions { SetCoordinates }

class SetCoordinatesAction {
  final double latitude;
  final double longitude;

  SetCoordinatesAction(this.latitude, this.longitude);

  @override
  toString() {
    return 'SetCoordinatesAction{latitude: $latitude, longitude: $longitude}';
  }
}
