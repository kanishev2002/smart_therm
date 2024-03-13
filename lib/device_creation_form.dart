import 'package:flutter/material.dart';

class DeviceCreationForm extends StatefulWidget {
  const DeviceCreationForm({super.key});

  @override
  State<DeviceCreationForm> createState() => _DeviceCreationFormState();
}

class _DeviceCreationFormState extends State<DeviceCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _deviceIPController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Form'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Validated, pass data back to parent widget
                Navigator.pop(context, {
                  'deviceName': _deviceNameController.text,
                  'deviceIP': _deviceIPController.text,
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
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
                  final ipRegExp = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
                  if (!ipRegExp.hasMatch(value)) {
                    return 'Please enter a valid IP address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
