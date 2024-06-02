import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GraphsPage extends StatelessWidget {
  GraphsPage({super.key});

  final controller = WebViewController()
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('progress: $progress');
        },
        onPageStarted: (String url) {
          debugPrint('started');
        },
        onPageFinished: (String url) {
          debugPrint('finished');
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('error: ${error.description}');
        },
      ),
    );

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThermostatControlBloc>().state;
    if (state.deviceData.isEmpty || !state.deviceData[state.selectedDevice].useMQTT) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Для отображения графиков необходимо настроить Home Assistant с подключенным MQTT',
          ),
        ),
      );
    }

    final device = state.deviceData[state.selectedDevice];
    final homeAssistantUrl = Uri(
      scheme: 'http',
      host: device.mqttData!.brokerIP,
      port: 8123,
    );
    controller.loadRequest(homeAssistantUrl);

    return WebViewWidget(
      controller: controller,
    );
  }
}
