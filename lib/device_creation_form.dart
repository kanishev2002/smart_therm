import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/constants.dart';
import 'package:smart_therm/models/mqtt_data.dart';
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
  final _mqttIPController = TextEditingController();
  final _mqttUsernameController = TextEditingController();
  final _mqttPasswordController = TextEditingController();
  bool _usePID = false;
  bool _useMQTT = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ThermostatControlBloc, ThermostatControlState>(
      listener: (context, state) {
        if (state.status.isError) {
          Utilities.showError(
            context,
            content: const Text(
              AddEditFormConstants.connectionError,
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
              title: const Text(AddEditFormConstants.addTitle),
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
                        useMQTT: _useMQTT,
                        mqttData: _useMQTT
                            ? MQTTData(
                                brokerIP: _mqttIPController.text,
                                username: _mqttUsernameController.text,
                                password: _mqttPasswordController.text,
                              )
                            : null,
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
                            labelText: AddEditFormConstants.deviceNameLabel,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AddEditFormConstants.emptyDeviceNameError;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        if (!_useMQTT)
                          TextFormField(
                            controller: _deviceIPController,
                            decoration: const InputDecoration(
                              labelText: AddEditFormConstants.ipFieldLabel,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AddEditFormConstants.emptyIpError;
                              }
                              // Basic IP validation
                              final ipRegExp = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
                              if (!ipRegExp.hasMatch(value)) {
                                return AddEditFormConstants.incorrectIpError;
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
                            const Text(AddEditFormConstants.usePIDLabel),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _useMQTT,
                              onChanged: (value) {
                                setState(() {
                                  _useMQTT = value!;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text(AddEditFormConstants.useMQTTLabel),
                          ],
                        ),
                        if (_useMQTT)
                          MQTTInfoForm(
                            ipController: _mqttIPController,
                            usernameController: _mqttUsernameController,
                            passwordController: _mqttPasswordController,
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

class MQTTInfoForm extends StatelessWidget {
  const MQTTInfoForm({
    required this.ipController,
    required this.usernameController,
    required this.passwordController,
    super.key,
  });

  final TextEditingController ipController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: ipController,
          decoration: const InputDecoration(
            labelText: AddEditFormConstants.mqttAddressLabel,
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AddEditFormConstants.emptyIpError;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: AddEditFormConstants.mqttUsernameLabel,
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AddEditFormConstants.thisFieldIsRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: AddEditFormConstants.mqttPasswordLabel,
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AddEditFormConstants.thisFieldIsRequired;
            }
            return null;
          },
        ),
      ],
    );
  }
}
