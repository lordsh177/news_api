import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNews extends NewsEvent {
  final String query;
  final bool refresh;

  FetchNews(this.query, {this.refresh = false});

  @override
  List<Object?> get props => [query, refresh];
}

class LoadMoreNews extends NewsEvent {
  final String query;

  LoadMoreNews(this.query);

  @override
  List<Object?> get props => [query];
}
