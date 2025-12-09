import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ArticleWebView extends StatelessWidget {
  final String url;

  const ArticleWebView({super.key, required this.url});

  Future<void> _openUrl() async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    // On Web → just open instantly
    if (kIsWeb) {
      _openUrl();
      return Scaffold(
        appBar: AppBar(title: const Text("Opening Article...")),
        body: const Center(
          child: Text("The article opened in a new browser tab."),
        ),
      );
    }

    // On Mobile → open external browser too
    _openUrl();

    return Scaffold(
      appBar: AppBar(title: const Text("Opening Article...")),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
