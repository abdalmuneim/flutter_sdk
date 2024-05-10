import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as webviewf;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;

class ThreeDSPage extends StatefulWidget {
  final String? html;
  final String? returnURL;

  const ThreeDSPage(this.html, this.returnURL, {Key? key}) : super(key: key);

  @override
  _ThreeDSPageState createState() => _ThreeDSPageState();
}

class _ThreeDSPageState extends State<ThreeDSPage> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      // WebViewController.platform = AndroidWebView();
    }
  }

  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("3DS")),
      body: Builder(builder: (BuildContext context) {
        return WebViewWidget(
          controller: webviewf.WebViewController()
            ..setJavaScriptMode(webviewf.JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              webviewf.NavigationDelegate(
                onHttpAuthRequest: (request) {},
                onNavigationRequest: (request) {
                  print('allowing navigation to $request');
                  if (request.url.startsWith(widget.returnURL ?? "")) {
                    Navigator.of(context).pop();
                    return webviewf.NavigationDecision.prevent;
                  }
                  return webviewf.NavigationDecision.navigate;
                },
                onPageFinished: (url) {
                  print('Page finished loading: $url');
                  // if (url.startsWith(widget.returnURL)) {
                  //   Navigator.of(context).pop();
                  // }
                },
                onPageStarted: (url) {
                  print('Page started loading: $url, ${widget.returnURL}');
                  if (url.startsWith(widget.returnURL ?? "")) {
                    Navigator.of(context).pop();
                  }
                },
                onProgress: (progress) {
                  print('WebView is loading (progress : $progress%)');
                },
                onUrlChange: (change) {},
                onWebResourceError: (error) {
                  print('WebResourceError: $error');

                  if (Platform.isIOS) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            )
            ..addJavaScriptChannel(
              "Toaster",
              onMessageReceived: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message.message)),
                );
              },
            )
            ..setBackgroundColor(const Color(0x00000000))
            ..loadHtmlString(widget.html ?? ""),
        );
      }),
    );
  }
}
