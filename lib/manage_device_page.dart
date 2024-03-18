import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';
import 'package:smart_therm/temperature_circle.dart';
import 'package:smart_therm/temperature_preset_button.dart';

class ManageDevicePage extends StatelessWidget {
  const ManageDevicePage({
    required this.heroTag,
    required this.targetTemperature,
    required this.temperatureCircle,
    required this.presets,
    required this.controlType,
    super.key,
  });

  final String heroTag;
  final double targetTemperature;
  final TemperatureCircle temperatureCircle;
  final TemperaturePresets presets;
  final ControlType controlType;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThermostatControlBloc, ThermostatControlState>(
      builder: (context, state) {
        final selectedDevice = state.deviceData[state.selectedDevice];
        return Scaffold(
          appBar: AppBar(
            title: Text(temperatureCircle.label ?? ''),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Hero(
                    tag: heroTag,
                    child: TemperatureCircle(
                      temperature: selectedDevice.heatingTemperature,
                      minTemperature: temperatureCircle.minTemperature,
                      maxTemperature: temperatureCircle.maxTemperature,
                      icon: temperatureCircle.icon,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Set Target Temperature',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.spaceAround,
                    runSpacing: 16,
                    spacing: 8,
                    children: [
                      TemperaturePresetButton(
                        temperature: presets.normal,
                        title: 'Normal ☀️',
                        type: controlType,
                      ),
                      TemperaturePresetButton(
                        temperature: presets.hot,
                        title: 'Hot 🔥',
                        type: controlType,
                      ),
                      TemperaturePresetButton(
                        temperature: presets.eco,
                        title: 'Eco 🌱',
                        type: controlType,
                      ),
                      TemperaturePresetButton(
                        temperature: presets.custom,
                        title: 'Custom ⚙️',
                        type: controlType,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TemperaturePresets {
  TemperaturePresets({
    required this.normal,
    required this.hot,
    required this.eco,
    required this.custom,
  });

  final int normal;
  final int hot;
  final int eco;
  int custom;
}

enum ControlType { temperature, hotWater }
