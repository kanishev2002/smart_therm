import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_therm/models/weather/forecast_day_data.dart';

part 'forecast_day.freezed.dart';
part 'forecast_day.g.dart';

@freezed
class ForecastDay with _$ForecastDay {
  factory ForecastDay({
    required ForecastDayData day,
  }) = _ForecastDay;

  factory ForecastDay.fromJson(Map<String, dynamic> json) => _$ForecastDayFromJson(json);
}
