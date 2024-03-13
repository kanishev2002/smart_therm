import 'package:flutter/material.dart';
import 'package:smart_therm/temperature_circle.dart';
import 'package:smart_therm/temperature_circle_hero_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double temperature = 6;
  bool burnerOn = false;
  static const double _minTemperature = -20;
  static const double _maxTemperature = 35;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.spaceAround,
            runSpacing: 16,
            children: [
              const TemperatureCircleHeroTransition(
                temperatureCircle: TemperatureCircle(
                  temperature: 20,
                  targetTemperature: 21,
                  minTemperature: _minTemperature,
                  maxTemperature: _maxTemperature,
                  label: 'Water heater temperature',
                  icon: Icon(
                    Icons.local_fire_department,
                    size: 28,
                    color: Colors.orange,
                  ),
                ),
                heroTag: 'Water heater temperature',
              ),
              TemperatureCircleHeroTransition(
                temperatureCircle: TemperatureCircle(
                  temperature: temperature,
                  targetTemperature: temperature,
                  maxTemperature: _maxTemperature,
                  minTemperature: _minTemperature,
                  label: 'Hot water temperature',
                  icon: const Icon(
                    Icons.water_drop_outlined,
                    size: 28,
                    color: Colors.blue,
                  ),
                ),
                heroTag: 'Hot water temperature',
              ),
              const TemperatureCircle(
                temperature: 18,
                minTemperature: _minTemperature,
                maxTemperature: _maxTemperature,
                label: 'Room temp 1',
                icon: Icon(
                  Icons.device_thermostat,
                  size: 28,
                  color: Colors.redAccent,
                ),
              ),
              const TemperatureCircle(
                temperature: 6,
                minTemperature: _minTemperature,
                maxTemperature: _maxTemperature,
                label: 'Room temp 2',
                icon: Icon(
                  Icons.thermostat,
                  size: 28,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            children: [
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    burnerOn = !burnerOn;
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  foregroundColor: burnerOn ? Colors.blue : Colors.orange,
                ),
                child: Icon(
                  burnerOn ? Icons.whatshot : Icons.whatshot_outlined,
                  color: burnerOn ? Colors.orange : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Burner ${burnerOn ? "ON" : "OFF"}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
