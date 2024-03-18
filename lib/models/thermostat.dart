import 'package:freezed_annotation/freezed_annotation.dart';

part 'thermostat.freezed.dart';
part 'thermostat.g.dart';

@freezed
class Thermostat with _$Thermostat {
  factory Thermostat({
    required String name,
    required bool heatingOn,
    required bool hotWaterOn,
    required double heatingTemperature,
    required double hotWaterTemperature,
    required double? roomTemperature1,
    required double? roomTemperature2,
  }) = _Thermostat;

  factory Thermostat.fromJson(Map<String, dynamic> json) =>
      _$ThermostatFromJson(json);
}
