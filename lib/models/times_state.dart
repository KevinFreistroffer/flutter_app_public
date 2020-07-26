import 'package:meta/meta.dart';

@immutable
class TimesState {
  final double sunrise;
  final double sunset;
  final double dayLength;

  TimesState({
    @required this.sunrise,
    @required this.sunset,
    @required this.dayLength,
  });

  TimesState copyWith({
    @required sunrise,
    @required sunset,
    @required dayLength,
  }) {
    return TimesState(
      sunrise: sunrise,
      sunset: sunset,
      dayLength: dayLength,
    );
  }

  factory TimesState.initial() {
    return TimesState(
      sunrise: null,
      sunset: null,
      dayLength: null,
    );
  }

  @override
  String toString() {
    return 'Times{sunrise: $sunrise, sunset: $sunset, dayLength: $dayLength}';
  }
}
