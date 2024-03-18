import 'package:smart_therm/models/thermostat.dart';

class NetworkService {
  NetworkService({
    required this.thermostatUrl,
  });

  final Uri thermostatUrl;

  Future<List<Thermostat>> getThermostats() async {
    await Future<void>.delayed(const Duration(seconds: 10));
    return [
      Thermostat(
        name: 'Thermostat 1',
        heatingOn: true,
        hotWaterOn: true,
        heatingTemperature: 22,
        hotWaterTemperature: 50,
        roomTemperature1: 23,
        roomTemperature2: 21,
      ),
    ];
  }
}
