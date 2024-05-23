import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/constants.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';
import 'package:smart_therm/on_off_button.dart';
import 'package:smart_therm/temperature_circle.dart';
import 'package:smart_therm/temperature_preset_button.dart';
import 'package:smart_therm/utils/utilities.dart';

class ManageDevicePage extends StatelessWidget {
  const ManageDevicePage({
    required this.heroTag,
    required this.targetTemperature,
    required this.temperatureCircle,
    required this.controlType,
    super.key,
  });

  final String heroTag;
  final double targetTemperature;
  final TemperatureCircle temperatureCircle;
  final ControlType controlType;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ThermostatControlBloc, ThermostatControlState>(
      listener: (context, state) {
        if (state.status.isError) {
          Utilities.showError(
            context,
            content: const Text(
              ManageDevicesPageConstants.couldNotChangeSettings,
            ),
          );
        }
      },
      builder: (context, state) {
        final selectedDevice = state.deviceData[state.selectedDevice];
        final data = selectedDevice.data!;

        final TemperaturePresets presets;
        if (controlType == ControlType.temperature) {
          if (selectedDevice.usePID) {
            presets = TemperaturePresets(
              normal: 22,
              hot: 30,
              eco: 10,
              custom: state.customHeatingTemperature,
            );
          } else {
            presets = TemperaturePresets(
              normal: 50,
              hot: 80,
              eco: 40,
              custom: state.customHeatingTemperature,
            );
          }
        } else {
          presets = TemperaturePresets(
            normal: 30,
            hot: 50,
            eco: 25,
            custom: state.customHotWaterTemperature,
          );
        }
        final minTemperature = controlType == ControlType.hotWater ? 20 : 5;
        final maxTemperature = controlType == ControlType.hotWater
            ? 50
            : selectedDevice.usePID
                ? 30
                : 90;
        final temperature = controlType == ControlType.temperature
            ? selectedDevice.heatingTemperature
            : selectedDevice.hotWaterTemperature;
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
                      targetTemperature: temperature.toDouble(),
                      minTemperature: minTemperature.toDouble(),
                      maxTemperature: maxTemperature.toDouble(),
                      icon: temperatureCircle.icon,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ManageDevicesPageConstants.setTargetTemperature,
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
                        title: '${ManageDevicesPageConstants.normalPreset} ☀️',
                        type: controlType,
                      ),
                      TemperaturePresetButton(
                        temperature: presets.hot,
                        title: '${ManageDevicesPageConstants.hotPreset} 🔥',
                        type: controlType,
                      ),
                      TemperaturePresetButton(
                        temperature: presets.eco,
                        title: '${ManageDevicesPageConstants.ecoPreset} 🌱',
                        type: controlType,
                      ),
                      TemperaturePresetButton(
                        temperature: presets.custom,
                        title: '${ManageDevicesPageConstants.customPreset} ⚙️',
                        type: controlType,
                        isCustom: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  OnOffButton(
                    onPressed: () {
                      context.read<ThermostatControlBloc>().add(
                            controlType == ControlType.temperature
                                ? const ToggleHeating()
                                : const ToggleHotWater(),
                          );
                    },
                    active: controlType == ControlType.temperature
                        ? data.heatingOn
                        : data.hotWaterOn,
                    label: controlType == ControlType.temperature
                        ? ManageDevicesPageConstants.centralHeating
                        : ManageDevicesPageConstants.hotWater,
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
