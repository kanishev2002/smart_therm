import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_therm/models/thermostat.dart';

part 'thermostat_control_state.freezed.dart';
part 'thermostat_control_state.g.dart';

enum LoadingStatus {
  loading,
  done,
  error;

  bool get isLoading => this == LoadingStatus.loading;
  bool get isDone => this == LoadingStatus.done;
  bool get isError => this == LoadingStatus.error;
}

@freezed
class ThermostatControlState with _$ThermostatControlState {
  factory ThermostatControlState({
    required List<Thermostat> deviceData,
    required int customHeatingTemperature,
    required int customHotWaterTemperature,
    @Default(0) int selectedDevice,
    @Default(LoadingStatus.loading) LoadingStatus status,
  }) = _ThermostatControlState;

  factory ThermostatControlState.fromJson(Map<String, dynamic> json) =>
      _$ThermostatControlStateFromJson(json);
}
