import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import 'dart:typed_data';

class PolicyPage extends StatefulWidget {
  final String title; // e.g., "Terms and Conditions"
  final String assetPath; // e.g., "assets/docs/Terms And Conditions.htm"

  const PolicyPage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  late final WebViewController _webViewController;
  String _htmlContent = "";

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted);
    }
    _loadLocalHtml();
  }

  Future<void> _loadLocalHtml() async {
    try {
      final bytes = await rootBundle.load(widget.assetPath);
      print("Bytes loaded from asset: ${bytes.lengthInBytes}");
      final Uint8List byteList = bytes.buffer.asUint8List();

      String fileText;
      if (kIsWeb) {
        fileText = utf8.decode(byteList);
      } else {
        fileText = await CharsetConverter.decode("utf-8", byteList);
      }
      print("Decoded file text length before cleanup: ${fileText.length}");

      // Clean up unexpected characters (like the replacement symbol)
      fileText = fileText.replaceAll('�', '');
      print("Decoded file text length after cleanup: ${fileText.length}");

      setState(() {
        _htmlContent = fileText;
      });

      if (!kIsWeb) {
        final base64Data = base64Encode(utf8.encode(fileText));
        final dataUri = Uri.parse("data:text/html;base64,$base64Data");
        print("Data URI: $dataUri");
        _webViewController.loadRequest(dataUri);
      }
    } catch (e) {
      print("Error loading HTML file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        "Building PolicyPage. kIsWeb: $kIsWeb, _htmlContent length: ${_htmlContent.length}");
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _htmlContent.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : kIsWeb
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Html(data: _htmlContent),
                )
              : WebViewWidget(controller: _webViewController),
    );
  }
}
