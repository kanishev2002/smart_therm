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

final class ToggleHeating extends ThermostatControlEvent {
  const ToggleHeating();
}

final class ToggleHotWater extends ThermostatControlEvent {
  const ToggleHotWater();
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
    this.isCustom = false,
  });
  final int temperature;
  final bool isCustom;
}

final class SetWaterTemperature extends ThermostatControlEvent {
  const SetWaterTemperature({
    required this.temperature,
    this.isCustom = false,
  });
  final int temperature;
  final bool isCustom;
}

final class AppStartRefresh extends ThermostatControlEvent {
  const AppStartRefresh();
}

final class UpdateDevice extends ThermostatControlEvent {
  const UpdateDevice({
    required this.device,
    required this.index,
  });

  final Thermostat device;
  final int index;
}

final class DeleteDevice extends ThermostatControlEvent {
  const DeleteDevice({
    required this.index,
  });

  final int index;
}

final class AutomaticDataRefresh extends ThermostatControlEvent {
  const AutomaticDataRefresh();
}
