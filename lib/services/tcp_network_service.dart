part of 'network_service.dart';

class _TCPNetworkService implements _NetworkServiceImpl {
  _TCPNetworkService();

  TCPConnection? _currentConnection;

  @override
  Future<void> connectToThermostat(Thermostat t) async {
    await _currentConnection?.close();
    final deviceIP = InternetAddress(t.ip);
    _currentConnection = TCPConnection(ip: deviceIP);
    await _currentConnection!.start();
  }

  // @override
  // Future<ThermostatData> fetchNewThermostatData(Thermostat device) async {
  //   final ip = InternetAddress(device.ip);
  //   final connection = TCPConnection(ip: ip);
  //   await connection.start();
  //   final thermostatData = await getThermostatStatus(
  //     thermostatConnection: connection,
  //   );
  //   await connection.close();
  //   return thermostatData;
  // }

  @override
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

      final heatingEnabled = (boolFlags & Flags.heating) != 0;
      final hotWaterEnabled = (boolFlags & Flags.hotWater) != 0;
      final hasTemperatureSensors = (boolFlags & Flags.temperatureSensors) != 0;

      final boilerTemperature = controllerData.getFloat32(24, Endian.little);
      final hotWater = controllerData.getFloat32(40, Endian.little);
      final t1 = controllerData.getFloat32(56, Endian.little);
      final t2 = controllerData.getFloat32(60, Endian.little);

      return ThermostatData(
        heatingOn: heatingEnabled,
        hotWaterOn: hotWaterEnabled,
        hasTemperatureSensors: hasTemperatureSensors,
        actualHeatingTemperature: boilerTemperature,
        actualHotWaterTemperature: hotWater,
        roomTemperature1: t1,
        roomTemperature2: t2,
        miscellaneousData: _getMiscData(controllerData),
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  @override
  Future<ThermostatResponse> setParameters(
    Thermostat thermostat,
  ) async {
    final thermostatSettings = thermostat.data!;
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
      ..setFloat32(
        2,
        thermostat.heatingTemperature.toDouble(),
        Endian.little,
      )
      ..setFloat32(
        6,
        thermostat.heatingTemperature.toDouble(),
        Endian.little,
      )
      ..setFloat32(
        10,
        thermostat.hotWaterTemperature.toDouble(),
        Endian.little,
      );

    final request = ThermostatRequest(cmd0: 0x22, cmd: 0x24, buffer: data);

    final response = await _currentConnection!.submitRequest(request);

    return response;
  }

  MiscellaneousData _getMiscData(ByteData controllerData) {
    final boolFlags = controllerData.getInt16(6, Endian.little);

    final openThermStatus = controllerData.getInt16(8, Endian.little);
    final boilerStatus = controllerData.getInt32(20, Endian.little);
    final retT = controllerData.getFloat32(28, Endian.little);
    final modulation = controllerData.getFloat32(44, Endian.little);
    final pressure = controllerData.getFloat32(48, Endian.little);

    return MiscellaneousData(
      secondHeatingCircuitAvailable: (boolFlags & 0x20) != 0,
      burnerOn: boilerStatus & 0x08 != 0,
      openThermStatus: openThermStatus,
      boilerStatus: boilerStatus,
      returningTemp: retT,
      modulation: modulation,
      pressure: pressure,
    );
  }

  void _printDebugInfo(ByteData controllerData) {
    final boolFlags = controllerData.getInt16(6, Endian.little);

    final openThermStatus = controllerData.getInt16(8, Endian.little);
    final boilerStatus = controllerData.getInt32(20, Endian.little);
    final boilerT = controllerData.getFloat32(24, Endian.little);
    final retT = controllerData.getFloat32(28, Endian.little);
    final tSet = controllerData.getFloat32(32, Endian.little);
    final tSet_r = controllerData.getFloat32(36, Endian.little);
    final hotWaterTemp = controllerData.getFloat32(40, Endian.little);
    final modulation = controllerData.getFloat32(44, Endian.little);
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
hotWaterTemp: $hotWaterTemp
modulation: $modulation
Pressure: $pressure
Status: $status
t1: $t1
t2: $t2
''');
  }
}

class Flags {
  static const heating = 0x01;
  static const hotWater = 0x02;
  static const temperatureSensors = 0x40;
}
