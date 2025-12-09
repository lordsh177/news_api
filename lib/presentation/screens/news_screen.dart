import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/news_bloc.dart';
import '../../logic/bloc/news_event.dart';
import '../../logic/bloc/news_state.dart';
// ignore: unused_import
import '../widgets/news_large_card.dart';
import '../widgets/news_large_carousel.dart';
import '../widgets/news_small_card.dart';
import '../../logic/cubit/theme_cubit.dart';
import 'article_webview.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  final List<Map<String, String>> categories = [
    {'label': 'All', 'q': 'latest'},
    {'label': 'Gaming', 'q': 'gaming'},
    {'label': 'Technology', 'q': 'technology'},
    {'label': 'Anime', 'q': 'anime'},
    {'label': 'Sports', 'q': 'sports'},
  ];

  String currentQuery = 'latest';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        final q = categories[_tabController.index]['q']!;
        currentQuery = q;
        _searchController.text = '';
        context.read<NewsBloc>().add(FetchNews(q));
      }
    });

    context.read<NewsBloc>().add(FetchNews(currentQuery));
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gnews',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.blue,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => themeCubit.toggle(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search news...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        final q = _searchController.text.trim();
                        currentQuery = q.isEmpty ? 'latest' : q;
                        context.read<NewsBloc>().add(FetchNews(currentQuery));
                      },
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (v) {
                    final q = v.trim();
                    currentQuery = q.isEmpty ? 'latest' : q;
                    context.read<NewsBloc>().add(FetchNews(currentQuery));
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: categories.map((c) => Tab(text: c['label'])).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: BlocConsumer<NewsBloc, NewsState>(
        listener: (context, state) {
          if (state is NewsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is NewsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NewsLoaded) {
            final articles = state.articles;
            if (articles.isEmpty) {
              return const Center(child: Text('No results'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NewsBloc>().add(
                  FetchNews(currentQuery, refresh: true),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IgnorePointer(
                      ignoring: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: NewsLargeCarousel(articles: articles),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'All Posts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final a = articles[index];
                        return GestureDetector(
                          onTap: () => _openArticle(context, a.url),
                          child: NewsSmallCard(article: a),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: articles.length,
                    ),

                    const SizedBox(height: 12),

                    if (state.hasMore)
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<NewsBloc>().add(
                              LoadMoreNews(currentQuery),
                            );
                          },
                          child: const Text('Load More'),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }
          if (state is NewsError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Search or select a category.'));
        },
      ),
    );
  }

  void _openArticle(BuildContext context, String url) {
    if (url.isNotEmpty) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ArticleWebView(url: url)));
    }
  }
}
