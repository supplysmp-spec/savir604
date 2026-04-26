// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobCheckoutPage extends StatefulWidget {
  const PaymobCheckoutPage({Key? key}) : super(key: key);

  @override
  State<PaymobCheckoutPage> createState() => _PaymobCheckoutPageState();
}

class _PaymobCheckoutPageState extends State<PaymobCheckoutPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    String url = args['url'];

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // ✅ الجديد
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay Online"),
      ),
      body: WebViewWidget(controller: controller), // ✅ الجديد
    );
  }
}
