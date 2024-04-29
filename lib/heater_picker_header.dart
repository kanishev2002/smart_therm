import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';

class HeaterPickerHeader extends StatelessWidget {
  const HeaterPickerHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThermostatControlBloc, ThermostatControlState>(
      builder: (context, state) {
        final devices = state.deviceData;
        if (devices.isEmpty) {
          return Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineSmall,
          );
        }
        return TextButton(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (ctx) {
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, idx) {
                      final device = devices[idx];
                      final isSelected = idx == state.selectedDevice;
                      return ListTile(
                        title: Text(device.name),
                        trailing: isSelected ? const Icon(Icons.check) : null,
                        onTap: () {
                          context.read<ThermostatControlBloc>().add(
                                SelectDevice(
                                  index: idx,
                                ),
                              );
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                devices[state.selectedDevice].name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Icon(
                Icons.arrow_drop_down,
              ),
            ],
          ),
        );
      },
    );
  }
}
