import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/manage_device_page.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';
import 'package:smart_therm/temperature_circle.dart';
import 'package:smart_therm/temperature_circle_hero_transition.dart';
import 'package:smart_therm/utils/utilities.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ThermostatControlBloc, ThermostatControlState>(
      listener: (context, state) {
        final isDisplaying = ModalRoute.of(context)?.isCurrent ?? false;
        if (state.status.isError && isDisplaying) {
          Utilities.showError(
            context,
            content: const Text(
              'Could not receive data from thermostat. '
              'Please check your network connection and try again.',
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.deviceData.isEmpty) {
          return const Center(child: Text('No devices added yet'));
        }
        final device = state.deviceData[state.selectedDevice];
        final data = device.data!;
        final temp1 = data.roomTemperature1;
        final temp2 = data.roomTemperature2;
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
                        temperature: device.heatingTemperature.toDouble(),
                        targetTemperature: data.actualHeatingTemperature,
                        minTemperature: -5,
                        maxTemperature: device.usePID ? 35 : 100,
                        label: 'Water heater temperature',
                        icon: const Icon(
                          Icons.local_fire_department,
                          size: 28,
                          color: Colors.orange,
                        ),
                      ),
                      heroTag: 'Water heater temperature',
                      type: ControlType.temperature,
                    ),
                    TemperatureCircleHeroTransition(
                      temperatureCircle: TemperatureCircle(
                        temperature: device.hotWaterTemperature.toDouble(),
                        targetTemperature: data.actualHotWaterTemperature,
                        maxTemperature: 100,
                        minTemperature: 5,
                        label: 'Hot water temperature',
                        icon: const Icon(
                          Icons.water_drop_outlined,
                          size: 28,
                          color: Colors.blue,
                        ),
                      ),
                      heroTag: 'Hot water temperature',
                      type: ControlType.hotWater,
                    ),
                    if (data.hasTemperatureSensors) ...[
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
