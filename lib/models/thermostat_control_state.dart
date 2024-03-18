import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_therm/models/thermostat.dart';

part 'thermostat_control_state.freezed.dart';

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
    @Default(0) int selectedDevice,
    @Default(LoadingStatus.loading) LoadingStatus status,
  }) = _ThermostatControlState;
}
