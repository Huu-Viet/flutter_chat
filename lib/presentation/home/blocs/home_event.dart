part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

final class LoadHomeEvent extends HomeEvent {
  final int page;
  final int limit;

  const LoadHomeEvent({this.page = 1, this.limit = 20});

  @override
  List<Object> get props => [page, limit];
}

final class LoadMoreHomeEvent extends HomeEvent {
  const LoadMoreHomeEvent();

  @override
  List<Object> get props => const [];
}
