import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smart_therm/models/thermostat_data.dart';

part 'thermostat.freezed.dart';
part 'thermostat.g.dart';

@freezed
class Thermostat with _$Thermostat {
  factory Thermostat({
    required String name,
    required String ip,
    ThermostatData? data,
  }) = _Thermostat;

  factory Thermostat.fromJson(Map<String, dynamic> json) =>
      _$ThermostatFromJson(json);
}
