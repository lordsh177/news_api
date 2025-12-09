import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../data/models/news_article.dart';
import 'news_large_card.dart';
import '../screens/article_webview.dart';

class NewsLargeCarousel extends StatefulWidget {
  final List<NewsArticle> articles;

  const NewsLargeCarousel({super.key, required this.articles});

  @override
  State<NewsLargeCarousel> createState() => _NewsLargeCarouselState();
}

class _NewsLargeCarouselState extends State<NewsLargeCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);

  @override
  Widget build(BuildContext context) {
    if (widget.articles.isEmpty) return const SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;
    final double carouselHeight = screenWidth > 600 ? screenWidth * 0.35 : 220;

    return Column(
      children: [
        SizedBox(
          height: carouselHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.articles.length,
            itemBuilder: (context, index) {
              final article = widget.articles[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleWebView(url: article.url),
                    ),
                  );
                },
                child: NewsLargeCard(
                  article: article,
                  isCarousel: true,
                  height: carouselHeight,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        SmoothPageIndicator(
          controller: _controller,
          count: widget.articles.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            expansionFactor: 3,
            spacing: 6,
            activeDotColor: Colors.blue,
            dotColor: Colors.grey.shade600,
          ),
          onDotClicked: (index) {
            _controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          },
        ),
      ],
    );
  }
}
