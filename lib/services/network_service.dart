import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_therm/models/miscellaneous_data.dart';
import 'package:smart_therm/models/tcp_connection.dart';
import 'package:smart_therm/models/thermostat.dart';
import 'package:smart_therm/models/thermostat_data.dart';
import 'package:smart_therm/models/thermostat_request.dart';

part 'tcp_network_service.dart';
part 'mqtt_network_service.dart';
part 'network_service_impl.dart';

class NetworkService {
  NetworkService();

  late _NetworkServiceImpl _impl;

  Future<void> connectToThermostat(Thermostat t) async {
    _impl = t.useMQTT ? _MQTTNetworkService() : _TCPNetworkService();
    await _impl.connectToThermostat(t);
  }

  // Future<ThermostatData> updateThermostatData(Thermostat device) async {
  //   //await Future<void>.delayed(const Duration(seconds: 5));
  //   final ip = InternetAddress(device.ip);
  //   final connection = TCPConnection(ip: ip);
  //   await connection.start();
  //   final thermostatData = await getThermostatStatus(ip);
  // }

  // Future<ThermostatData> fetchNewThermostatData(Thermostat device) async {
  //   return _impl.fetchNewThermostatData(device);
  // }

  Future<ThermostatData> getThermostatStatus() async {
    return _impl.getThermostatStatus();
  }

  Future<void> setParameters(
    Thermostat thermostat,
  ) async {
    return _impl.setParameters(thermostat);
  }
}
