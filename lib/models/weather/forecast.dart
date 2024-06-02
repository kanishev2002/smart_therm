import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_therm/models/weather/forecast_day.dart';

part 'forecast.freezed.dart';
part 'forecast.g.dart';

@freezed
class Forecast with _$Forecast {
  factory Forecast({required List<ForecastDay> forecastday}) = _Forecast;

  factory Forecast.fromJson(Map<String, dynamic> json) => _$ForecastFromJson(json);
}
