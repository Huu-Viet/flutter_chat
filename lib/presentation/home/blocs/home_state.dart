part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

final class HomeInitial extends HomeState {
  @override
  List<Object?> get props => const [];
}

final class HomeLoading extends HomeState {
  @override
  List<Object?> get props => const [];
}

final class HomeLoaded extends HomeState {
  final List<Conversation> conversations;
  final int page;
  final int limit;
  final bool hasMore;
  final bool isLoadingMore;

  const HomeLoaded({
    required this.conversations,
    required this.page,
    required this.limit,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  HomeLoaded copyWith({
    List<Conversation>? conversations,
    int? page,
    int? limit,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HomeLoaded(
      conversations: conversations ?? this.conversations,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [conversations, page, limit, hasMore, isLoadingMore];
}

final class HomeFailure extends HomeState {
  final Failure failure;

  const HomeFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}