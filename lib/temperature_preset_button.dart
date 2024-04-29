import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/manage_device_page.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';

class TemperaturePresetButton extends StatelessWidget {
  const TemperaturePresetButton({
    required this.temperature,
    required this.title,
    required this.type,
    super.key,
  });

  final int temperature;
  final String title;
  final ControlType type;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThermostatControlBloc, ThermostatControlState>(
      builder: (context, state) {
        final deviceData = state.deviceData[state.selectedDevice].data!;
        final deviceTemp = switch (type) {
          ControlType.temperature => deviceData.heatingTemperature,
          ControlType.hotWater => deviceData.hotWaterTemperature,
        };
        final selected = deviceTemp == temperature;

        return ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            side: selected
                ? const MaterialStatePropertyAll(
                    BorderSide(
                      color: Colors.lightGreenAccent,
                    ),
                  )
                : null,
          ),
          onPressed: () {
            final bloc = context.read<ThermostatControlBloc>();
            final event = switch (type) {
              ControlType.temperature => SetHeatingTemperature(
                  temperature: temperature,
                ),
              ControlType.hotWater => SetWaterTemperature(
                  temperature: temperature,
                ),
            };
            bloc.add(event);
          },
          child: SizedBox(
            height: 80,
            width: MediaQuery.of(context).size.width / 2 - 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '$temperature°',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
