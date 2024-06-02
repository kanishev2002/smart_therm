import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_therm/models/weather/current_weather.dart';
import 'package:smart_therm/models/weather/forecast.dart';
import 'package:smart_therm/models/weather/location.dart';

part 'weather_api_response.freezed.dart';
part 'weather_api_response.g.dart';

@freezed
class WeatherApiResponse with _$WeatherApiResponse {
  factory WeatherApiResponse({
    required Location location,
    required CurrentWeather current,
    required Forecast forecast,
  }) = _WeatherApiResponse;

  factory WeatherApiResponse.fromJson(Map<String, dynamic> json) =>
      _$WeatherApiResponseFromJson(json);
}
