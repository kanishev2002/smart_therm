import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_therm/models/miscellaneous_data.dart';

part 'thermostat_data.freezed.dart';
part 'thermostat_data.g.dart';

@freezed
class ThermostatData with _$ThermostatData {
  factory ThermostatData({
    required bool heatingOn,
    required bool hotWaterOn,
    required bool hasTemperatureSensors,
    required double actualHeatingTemperature,
    required double actualHotWaterTemperature,
    required double roomTemperature1,
    required double roomTemperature2,
    required MiscellaneousData miscellaneousData,
  }) = _ThermostatData;

  factory ThermostatData.fromJson(Map<String, dynamic> json) =>
      _$ThermostatDataFromJson(json);
}
