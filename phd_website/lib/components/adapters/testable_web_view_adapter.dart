import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TestableWebViewAdapter extends StatefulWidget {
  final String destination;
  const TestableWebViewAdapter({
    super.key,
    required this.destination,
  });

  @override
  State<TestableWebViewAdapter> createState() => _TestableWebViewAdapterState();
}

class _TestableWebViewAdapterState extends State<TestableWebViewAdapter> {
  WebViewController? controller;

  @override
  void initState() {
    super.initState();
    if (WebViewPlatform.instance == null) {
      return;
    }
    controller = WebViewController()
      ..loadRequest(Uri.parse(widget.destination));
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return WebViewWidget(controller: controller!);
  }
}
