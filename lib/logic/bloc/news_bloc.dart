import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/news_repository.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository repository;

  NewsBloc(this.repository) : super(NewsInitial()) {
    on<FetchNews>(_onFetchNews);
    on<LoadMoreNews>(_onLoadMore);
  }

  Future<void> _onFetchNews(FetchNews event, Emitter<NewsState> emit) async {
    final query = event.query.trim().isEmpty ? 'latest' : event.query.trim();
    final startPage = event.refresh ? 1 : 1;

    emit(NewsLoading());
    try {
      final articles = await repository.searchNews(query, page: startPage);
      final hasMore = articles.length >= 10; // naive check
      emit(NewsLoaded(articles: articles, page: 1, hasMore: hasMore));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreNews event, Emitter<NewsState> emit) async {
    final current = state;
    if (current is NewsLoaded) {
      final nextPage = current.page + 1;

      try {
        final more = await repository.searchNews(event.query, page: nextPage);

        // FIXED MERGING OF LISTS
        final all = [...current.articles, ...more];

        final hasMore = more.length >= 10;

        emit(current.copyWith(articles: all, page: nextPage, hasMore: hasMore));
      } catch (e) {
        emit(NewsError(e.toString()));
      }
    }
  }
}
