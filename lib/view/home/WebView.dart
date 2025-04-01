 import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
//import 'package:flutter_inappwebview_platform_interface/src/web_uri.dart';

class WebView extends StatefulWidget {
  String url;
  String title;
   WebView({required this.url,required this.title,super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {


  late InAppWebViewController inAppWebViewController;

  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(widget.title)),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                  url: WebUri(widget.url)),
              onWebViewCreated: (InAppWebViewController controller) {
                inAppWebViewController = controller;
              },
              onProgressChanged:
                  (InAppWebViewController controller, int progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
            ),
            _progress < 1
                ? SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: _progress,
                // backgroundColor: Theme.of(context)
                //     .colorScheme
                //     .secondary
                //     .withOpacity(0.2),
                // valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
              ),
            )
                : const SizedBox(),
          ],
        ));
  }
}
