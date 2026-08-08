import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

  Future<void> _navigateToTicketUrl(String url) async {
    setState(() {
      isLoading = true;
    });

    await controller.stop();

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(
            url: url +
                (url.contains('&')
                    ? "&customerID=${SharedPref.getUserData().customerId}&email=${SharedPref.getUserData().email}"
                    : "?customerID=${SharedPref.getUserData().customerId}&email=${SharedPref.getUserData().email}"),
          ),
        ),
      );
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        controller.dispose();
        initializeScanner();
        await controller.start();
      }
    }
  }

  Future<void> _showManualEntryDialog() async {
    final TextEditingController textController = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter code manually"),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Ticket code or URL"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(textController.text.trim()),
            child: const Text("Continue"),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      _navigateToTicketUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Scan a Get Ticket QR Code'),
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
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: controller,
                      onDetect: _onDetect,
                    ),
                    _ScanFrameOverlay(),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 24,
                      child: Center(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _showManualEntryDialog,
                          icon: const Icon(Icons.keyboard),
                          label: const Text("Enter code manually"),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        await _navigateToTicketUrl(barcode.rawValue!);
        break;
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// A dimmed overlay with a clear square viewfinder in the center -- "Align the QR code within the
// frame" affordance from the mockup.
class _ScanFrameOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          const Spacer(),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Align the QR code within the frame",
            style: TextStyle(
              color: Colors.white,
              backgroundColor: Colors.black54,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
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
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}
