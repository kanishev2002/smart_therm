import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_therm/models/weather/weather_condition.dart';

part 'forecast_day_data.freezed.dart';
part 'forecast_day_data.g.dart';

@freezed
class ForecastDayData with _$ForecastDayData {
  factory ForecastDayData({
    required double maxtemp_c,
    required double mintemp_c,
    required WeatherCondition condition,
  }) = _ForecastDayData;

  factory ForecastDayData.fromJson(Map<String, dynamic> json) => _$ForecastDayDataFromJson(json);
}
