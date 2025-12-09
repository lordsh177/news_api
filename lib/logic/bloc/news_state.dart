import 'package:equatable/equatable.dart';
import '../../data/models/news_article.dart';

abstract class NewsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsArticle> articles;
  final int page;
  final bool hasMore;

  NewsLoaded({required this.articles, this.page = 1, this.hasMore = false});

  NewsLoaded copyWith({List<NewsArticle>? articles, int? page, bool? hasMore}) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [articles, page, hasMore];
}

class NewsError extends NewsState {
  final String message;
  NewsError(this.message);

  @override
  List<Object?> get props => [message];
}
