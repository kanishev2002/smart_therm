import 'package:flutter/material.dart';
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
    )
    ..loadRequest(Uri.parse('http://homeassistant.local:8123'));

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: controller,
    );
  }
}
