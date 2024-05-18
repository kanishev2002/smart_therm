import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/constants.dart';
import 'package:smart_therm/models/thermostat.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';
import 'package:smart_therm/utils/utilities.dart';

class DeviceEditingPage extends StatefulWidget {
  DeviceEditingPage({
    required this.index,
    required this.device,
    super.key,
  })  : _deviceIPController = TextEditingController(text: device.ip),
        _deviceNameController = TextEditingController(text: device.name);

  final int index;
  final Thermostat device;
  final TextEditingController _deviceNameController;
  final TextEditingController _deviceIPController;

  @override
  State<DeviceEditingPage> createState() => _DeviceEditingPageState();
}

class _DeviceEditingPageState extends State<DeviceEditingPage> {
  final _formKey = GlobalKey<FormState>();
  late var _usePID = widget.device.usePID;

  void _showDeleteDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(AddEditFormConstants.forgetDeviceDialogTitle),
          content: const Text(AddEditFormConstants.forgetDeviceDialogBody),
          actions: [
            TextButton(
              onPressed: () {
                ctx.read<ThermostatControlBloc>().add(
                      DeleteDevice(
                        index: widget.index,
                      ),
                    );
                Navigator.of(ctx).pop();
              },
              child: const Text(AddEditFormConstants.yes),
            ),
            TextButton(
              onPressed: Navigator.of(ctx).pop,
              child: const Text(AddEditFormConstants.no),
            ),
          ],
        );
      },
    );
  }

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
              title: const Text(AddEditFormConstants.editTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    if (state.status.isLoading) {
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      final currentDevice = state.deviceData[widget.index];
                      final updatedDevice = currentDevice.copyWith(
                        name: widget._deviceNameController.text,
                        ip: widget._deviceIPController.text,
                        usePID: _usePID,
                      );
                      context.read<ThermostatControlBloc>().add(
                            UpdateDevice(
                              device: updatedDevice,
                              index: widget.index,
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
                          controller: widget._deviceNameController,
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
                        TextFormField(
                          controller: widget._deviceIPController,
                          decoration: const InputDecoration(
                            labelText: AddEditFormConstants.ipFieldLabel,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AddEditFormConstants.emptyIpError;
                            }
                            // Basic IP validation
                            final ipRegExp =
                                RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
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
                        TextButton.icon(
                          onPressed: _showDeleteDialog,
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          label: const Text(
                            AddEditFormConstants.forgetThisDeviceLabel,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
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
