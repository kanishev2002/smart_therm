import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/models/thermostat.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';
import 'package:smart_therm/utils/utilities.dart';

class DeviceCreationForm extends StatefulWidget {
  const DeviceCreationForm({super.key});

  @override
  State<DeviceCreationForm> createState() => _DeviceCreationFormState();
}

class _DeviceCreationFormState extends State<DeviceCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _deviceIPController = TextEditingController();
  bool _usePID = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ThermostatControlBloc, ThermostatControlState>(
      listener: (context, state) {
        if (state.status.isError) {
          Utilities.showError(
            context,
            content: const Text(
              'Could not connect to device. '
              'Please make sure that the information you entered'
              ' is correct and try again',
            ),
          );
        } else if (state.status.isDone) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: !state.status.isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Device Form'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    if (state.status.isLoading) {
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      final newDevice = Thermostat(
                        name: _deviceNameController.text,
                        ip: _deviceIPController.text,
                        usePID: _usePID,
                        heatingTemperature: _usePID ? 22 : 50,
                      );
                      context.read<ThermostatControlBloc>().add(
                            AddDevice(
                              device: newDevice,
                            ),
                          );
                    }
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _deviceNameController,
                          decoration: const InputDecoration(
                            labelText: 'Device Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the device name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _deviceIPController,
                          decoration: const InputDecoration(
                            labelText: 'Device IP',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the device IP';
                            }
                            // Basic IP validation
                            final ipRegExp =
                                RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
                            if (!ipRegExp.hasMatch(value)) {
                              return 'Please enter a valid IP address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _usePID,
                              onChanged: (value) {
                                setState(() {
                                  _usePID = value!;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text('Use PID'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.status.isLoading) ...[
                  const Positioned.fill(
                    child: AbsorbPointer(),
                  ),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
