import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/manage_device_page.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';
import 'package:smart_therm/temperature_circle.dart';
import 'package:smart_therm/temperature_circle_hero_transition.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThermostatControlBloc, ThermostatControlState>(
      builder: (context, state) {
        if (state.status.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.deviceData.isEmpty) {
          return const Center(child: Text('No devices added yet'));
        }
        final device = state.deviceData[state.selectedDevice];
        final data = device.data!;
        final temp1 = data.roomTemperature1!;
        final temp2 = data.roomTemperature2 ?? temp1;
        final roomTemperature = (temp1 + temp2) / 2;
        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<ThermostatControlBloc>();
            // ignore: cascade_invocations
            bloc.add(const FetchThermostatData());
            await bloc.stream.first;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  runSpacing: 16,
                  children: [
                    TemperatureCircleHeroTransition(
                      temperatureCircle: TemperatureCircle(
                        temperature: roomTemperature,
                        targetTemperature: device.data!.heatingTemperature,
                        minTemperature: -5,
                        maxTemperature: 35,
                        label: 'Water heater temperature',
                        icon: const Icon(
                          Icons.local_fire_department,
                          size: 28,
                          color: Colors.orange,
                        ),
                      ),
                      heroTag: 'Water heater temperature',
                      presets: TemperaturePresets(
                        normal: 22,
                        hot: 30,
                        eco: 10,
                        custom: 15,
                      ),
                      type: ControlType.temperature,
                    ),
                    TemperatureCircleHeroTransition(
                      temperatureCircle: TemperatureCircle(
                        temperature: data.hotWaterTemperature,
                        targetTemperature: data.hotWaterTemperature,
                        maxTemperature: 100,
                        minTemperature: 0,
                        label: 'Hot water temperature',
                        icon: const Icon(
                          Icons.water_drop_outlined,
                          size: 28,
                          color: Colors.blue,
                        ),
                      ),
                      heroTag: 'Hot water temperature',
                      presets: TemperaturePresets(
                        normal: 50,
                        hot: 80,
                        eco: 40,
                        custom: 60,
                      ),
                      type: ControlType.hotWater,
                    ),
                    TemperatureCircle(
                      temperature: temp1,
                      minTemperature: 0,
                      maxTemperature: 35,
                      label: 'Room temp 1',
                      icon: const Icon(
                        Icons.device_thermostat,
                        size: 28,
                        color: Colors.redAccent,
                      ),
                    ),
                    TemperatureCircle(
                      temperature: temp2,
                      minTemperature: 0,
                      maxTemperature: 35,
                      label: 'Room temp 2',
                      icon: const Icon(
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
                        context
                            .read<ThermostatControlBloc>()
                            .add(const ToggleBurner());
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        foregroundColor:
                            data.heatingOn ? Colors.blue : Colors.orange,
                      ),
                      child: Icon(
                        data.heatingOn
                            ? Icons.whatshot
                            : Icons.whatshot_outlined,
                        color: data.heatingOn ? Colors.orange : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Burner ${data.heatingOn ? "ON" : "OFF"}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}