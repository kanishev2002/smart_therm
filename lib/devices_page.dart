import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/device_creation_form.dart';
import 'package:smart_therm/models/thermostat.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  static const _colors = [
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.purple,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThermostatControlBloc, ThermostatControlState>(
      builder: (context, state) {
        final devices = state.deviceData;
        final bloc = context.read<ThermostatControlBloc>();
        return Scaffold(
          floatingActionButton: TextButton(
            onPressed: () async {
              final deviceData =
                  await showModalBottomSheet<Map<String, String>>(
                context: context,
                builder: (ctx) {
                  return const DeviceCreationForm();
                },
              );
              if (deviceData != null) {
                bloc.add(
                  AddDevice(
                    device: Thermostat(
                      name: deviceData['deviceName']!,
                      ip: deviceData['deviceIP']!,
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add new device'),
          ),
          body: SafeArea(
            child: ListView.separated(
              itemBuilder: (context, idx) {
                return ListTile(
                  leading: Icon(
                    Icons.hvac,
                    color: _colors[idx % _colors.length],
                    size: 40,
                  ),
                  title: Text(devices[idx].name),
                  // trailing: const Icon(Icons.arrow_forward_ios),
                  // onTap: () => Navigator.of(context).push(
                  //   MaterialPageRoute<void>(
                  //     builder: (ctx) {
                  //       return Scaffold(body: Text(devices[idx]));
                  //     },
                  //   ),
                  // ),
                );
              },
              separatorBuilder: (_, __) => const Divider(
                color: Colors.grey,
              ),
              itemCount: devices.length,
            ),
          ),
        );
      },
    );
  }
}
