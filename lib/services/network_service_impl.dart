part of 'network_service.dart';

abstract interface class _NetworkServiceImpl {
  _NetworkServiceImpl();

  Future<void> connectToThermostat(Thermostat device);

  // Future<ThermostatData> fetchNewThermostatData(Thermostat device);

  Future<ThermostatData> getThermostatStatus();

  Future<void> setParameters(Thermostat device);
}
