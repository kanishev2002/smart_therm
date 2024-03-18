part of 'thermostat_control_bloc.dart';

abstract base class ThermostatControlEvent {
  const ThermostatControlEvent();
}

final class FetchThermostatData extends ThermostatControlEvent {
  const FetchThermostatData();
}

final class SelectDevice extends ThermostatControlEvent {
  const SelectDevice({
    required this.index,
  });

  final int index;
}

final class ToggleBurner extends ThermostatControlEvent {
  const ToggleBurner();
}

final class AddDevice extends ThermostatControlEvent {
  const AddDevice({
    required this.device,
  });

  final Thermostat device;
}

final class SetHeatingTemperature extends ThermostatControlEvent {
  const SetHeatingTemperature({
    required this.temperature,
  });
  final int temperature;
}

final class SetWaterTemperature extends ThermostatControlEvent {
  const SetWaterTemperature({
    required this.temperature,
  });
  final int temperature;
}
