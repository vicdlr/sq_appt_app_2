import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../SharedPrefrence/SharedPrefrence.dart';

class GetTicket extends StatefulWidget {
  const GetTicket({super.key});

  @override
  State<GetTicket> createState() => _GetTicketState();
}

class _GetTicketState extends State<GetTicket> {
  late MobileScannerController controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeScanner();
  }

  void initializeScanner() {
    controller = MobileScannerController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Scan QR Code'),
          actions: [
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: controller.torchState,
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off);
                    case TorchState.on:
                      return const Icon(Icons.flash_on);
                  }
                },
              ),
              onPressed: () => controller.toggleTorch(),
            ),
          ],
        ),
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : MobileScanner(
                  controller: controller,
                  onDetect: _onDetect,
                ),
        ),
      ],
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        String url = barcode.rawValue!;
        setState(() {
          isLoading = true;
        });

        // Stop the scanner before navigation
        await controller.stop();

        // Navigate to WebView
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WebViewPage(url: url + "/?ID=${SharedPref.getUserData().id}"),
            ),
          );

          // Reset scanner when returning
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            // Reinitialize the scanner
            controller.dispose();
            initializeScanner();
            await controller.start();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    log("url $url");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(url)),
      ),
    );
  }
}
