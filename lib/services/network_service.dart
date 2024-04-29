import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:smart_therm/models/tcp_connection.dart';
import 'package:smart_therm/models/thermostat.dart';
import 'package:smart_therm/models/thermostat_data.dart';
import 'package:smart_therm/models/thermostat_request.dart';

class NetworkService {
  NetworkService();

  TCPConnection? _currentConnection;

  Future<void> connectToThermostat(Thermostat t) async {
    await _currentConnection?.close();
    final deviceIP = InternetAddress(t.ip);
    _currentConnection = TCPConnection(ip: deviceIP);
    await _currentConnection!.start();
  }

  // Future<ThermostatData> updateThermostatData(Thermostat device) async {
  //   //await Future<void>.delayed(const Duration(seconds: 5));
  //   final ip = InternetAddress(device.ip);
  //   final connection = TCPConnection(ip: ip);
  //   await connection.start();
  //   final thermostatData = await getThermostatStatus(ip);
  // }

  Future<ThermostatData> fetchNewThermostatData(Thermostat device) async {
    final ip = InternetAddress(device.ip);
    final connection = TCPConnection(ip: ip);
    await connection.start();
    final thermostatData = await getThermostatStatus(
      thermostatConnection: connection,
    );
    await connection.close();
    return thermostatData;
  }

  Future<ThermostatData> getThermostatStatus({
    TCPConnection? thermostatConnection,
  }) async {
    try {
      final connection = thermostatConnection ?? _currentConnection;
      if (connection == null) {
        throw 'Not connected to any thermostat';
      }
      final request = ThermostatRequest(
        cmd0: 0x22,
        cmd: 0x23,
        buffer: Uint8List(0),
      );

      final response = await connection.submitRequest(request);
      final responseBuffer = response.buffer;

      const outputLength = 64;

      if (responseBuffer.length != outputLength) {
        throw 'Incorrect response size';
      }

      final controllerData = responseBuffer.buffer.asByteData();

      _printDebugInfo(controllerData);

      final boolFlags = controllerData.getInt16(6, Endian.little);

      final heatingEnabled = (boolFlags & Flags.heating.code) != 0;
      final hotWaterEnabled = (boolFlags & Flags.hotWater.code) != 0;

      final boilerTemperature = controllerData.getFloat32(24, Endian.little);
      final tSet = controllerData.getFloat32(32, Endian.little);
      final t1 = controllerData.getFloat32(56, Endian.little);
      final t2 = controllerData.getFloat32(60, Endian.little);

      return ThermostatData(
        heatingOn: heatingEnabled,
        hotWaterOn: hotWaterEnabled,
        heatingTemperature: boilerTemperature,
        hotWaterTemperature: tSet,
        roomTemperature1: t1,
        roomTemperature2: t2,
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<ThermostatResponse> setParameters(
    ThermostatData thermostatSettings,
  ) async {
    var flags = 0;
    if (thermostatSettings.heatingOn) {
      flags |= 0x01;
    }
    if (thermostatSettings.hotWaterOn) {
      flags |= 0x02;
    }
    final data = Uint8List(64);
    data.buffer.asByteData()
      ..setInt16(0, flags, Endian.little)
      ..setInt32(
        2,
        thermostatSettings.heatingTemperature.toInt(),
        Endian.little,
      );

    final request = ThermostatRequest(cmd0: 0x22, cmd: 0x24, buffer: data);

    final response = await _currentConnection!.submitRequest(request);

    return response;
  }

  void _printDebugInfo(ByteData controllerData) {
    final boolFlags = controllerData.getInt16(6, Endian.little);

    final openThermStatus = controllerData.getInt16(8, Endian.little);
    final boilerStatus = controllerData.getInt32(20, Endian.little);
    final boilerT = controllerData.getFloat32(24, Endian.little);
    final retT = controllerData.getFloat32(28, Endian.little);
    final tSet = controllerData.getFloat32(32, Endian.little);
    final tSet_r = controllerData.getFloat32(36, Endian.little);
    final dhw_t = controllerData.getFloat32(40, Endian.little);
    final pressure = controllerData.getFloat32(48, Endian.little);
    final status = controllerData.getInt32(52, Endian.little);
    final t1 = controllerData.getFloat32(56, Endian.little);
    final t2 = controllerData.getFloat32(60, Endian.little);

    debugPrint('''
Got boiler status:
Central heating enabled: ${(boolFlags & 0x01) != 0}
Hot water enabled: ${(boolFlags & 0x02) != 0}
Hot water present: ${(boolFlags & 0x10) != 0}
Second heating circuit available: ${(boolFlags & 0x20) != 0}
Outiside temp sensors available: ${(boolFlags & 0x40) != 0}
Water pressure sensor available: ${(boolFlags & 0x80) != 0}
MQTT available: ${(boolFlags & 0x100) != 0}
MQTT is used: ${(boolFlags & 0x200) != 0}
PID regulator available: ${(boolFlags & 0x400) != 0}
PID regulator is used: ${(boolFlags & 0x800) != 0}

OpenTherm status: $openThermStatus
Boiler status: $boilerStatus
Boiler temperature: $boilerT
retT: $retT
tSet: $tSet
tSet_r: $tSet_r
dhw_t: $dhw_t
Pressure: $pressure
Status: $status
t1: $t1
t2: $t2
''');
  }
}

enum Flags {
  heating(code: 0x01),
  hotWater(code: 0x02);

  const Flags({
    required this.code,
  });

  final int code;
}
