import 'package:flutter/material.dart';
import '../../data/models/news_article.dart';

class NewsTile extends StatelessWidget {
  final NewsArticle article;

  const NewsTile({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: article.image.isNotEmpty
          ? Image.network(article.image, width: 70, fit: BoxFit.cover)
          : Icon(Icons.image),
      title: Text(article.title),
      subtitle: Text(article.description),
      onTap: () => print(article.url),
    );
  }
}
