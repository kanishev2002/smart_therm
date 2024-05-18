import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/constants.dart';
import 'package:smart_therm/manage_device_page.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';

class TemperaturePresetButton extends StatelessWidget {
  const TemperaturePresetButton({
    required this.temperature,
    required this.title,
    required this.type,
    this.isCustom = false,
    this.updatePresets,
    super.key,
  });

  final int temperature;
  final String title;
  final ControlType type;
  final bool isCustom;
  final void Function(int)? updatePresets;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThermostatControlBloc, ThermostatControlState>(
      builder: (context, state) {
        final deviceData = state.deviceData[state.selectedDevice];
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
          onPressed: () async {
            var temperature = this.temperature;
            if (isCustom) {
              temperature = await showDialog<int>(
                    context: context,
                    builder: (context) => _CustomTemperatureDialog(
                      defaultTemperature: temperature,
                    ),
                  ) ??
                  temperature;
            }
            if (!context.mounted) {
              return;
            }
            final bloc = context.read<ThermostatControlBloc>();
            final event = switch (type) {
              ControlType.temperature => SetHeatingTemperature(
                  temperature: temperature,
                  isCustom: isCustom,
                ),
              ControlType.hotWater => SetWaterTemperature(
                  temperature: temperature,
                  isCustom: isCustom,
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

class _CustomTemperatureDialog extends StatelessWidget {
  _CustomTemperatureDialog({required this.defaultTemperature})
      : temperatureController = TextEditingController(
          text: defaultTemperature.toString(),
        );

  final int defaultTemperature;
  final TextEditingController temperatureController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ManageDevicesPageConstants.customTemperatureTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: temperatureController,
          decoration: const InputDecoration(
            labelText: ManageDevicesPageConstants.customTemperatureLabel,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return ManageDevicesPageConstants.emptyTemperatureError;
            }
            // Check if value is a positive integer
            if (int.tryParse(value) == null || int.parse(value) <= 0) {
              return ManageDevicesPageConstants.negativeTemperatureError;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(ManageDevicesPageConstants.cancel),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop(int.parse(temperatureController.text));
            }
          },
          child: const Text(ManageDevicesPageConstants.submit),
        ),
      ],
    );
  }
}
