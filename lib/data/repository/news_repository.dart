import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsRepository {
  final String apiKey = "3712174b53cfe4c1c4c8a285fd5436c2";

  final List<String> proxies = [
    "https://corsproxy.io/?",
    "https://thingproxy.freeboard.io/fetch/",
    "https://jsonp.afeld.me/?url=",
  ];

  Future<List<NewsArticle>> searchNews(
    String query, {
    int page = 1,
    int max = 10,
  }) async {
    query = query.trim().isEmpty ? "latest" : query.trim();

    final original = Uri.encodeFull(
      "https://gnews.io/api/v4/search?q=$query&lang=en&max=$max&page=$page&apikey=$apiKey",
    );

    Exception? lastError;

    for (final proxy in proxies) {
      final url = Uri.parse("$proxy$original");
      print("TRYING PROXY: $url");

      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          final response = await http
              .get(url)
              .timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            if (data == null || data["articles"] == null) return [];

            final List<dynamic> array = data["articles"];

            final seen = <String>{};
            final filtered = array.where((item) {
              final key = "${item['url']}_${item['title']}";
              if (seen.contains(key)) return false;
              seen.add(key);
              return true;
            }).toList();

            return filtered.map((e) => NewsArticle.fromJson(e)).toList();
          }

          lastError = Exception(
            "Proxy $proxy failed (status ${response.statusCode})",
          );
        } catch (e) {
          lastError = Exception("Proxy $proxy error: $e");
        }
      }
    }

    throw Exception("Failed to load news. $lastError");
  }
}
