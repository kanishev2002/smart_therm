import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_therm/models/weather/weather_condition.dart';

part 'current_weather.freezed.dart';
part 'current_weather.g.dart';

@freezed
class CurrentWeather with _$CurrentWeather {
  factory CurrentWeather({
    required double temp_c,
    required WeatherCondition condition,
    required int is_day,
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => _$CurrentWeatherFromJson(json);
}
