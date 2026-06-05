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
  final bool isUpdateOffsetSuccess;

  const HomeLoaded({
    required this.conversations,
    required this.page,
    required this.limit,
    required this.hasMore,
    this.isLoadingMore = false,
    this.isUpdateOffsetSuccess = false,
  });

  HomeLoaded copyWith({
    List<Conversation>? conversations,
    int? page,
    int? limit,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isUpdateOffsetSuccess,
  }) {
    return HomeLoaded(
      conversations: conversations ?? this.conversations,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isUpdateOffsetSuccess: isUpdateOffsetSuccess ?? this.isUpdateOffsetSuccess,
    );
  }

  @override
  List<Object?> get props => [conversations, page, limit, hasMore, isLoadingMore, isUpdateOffsetSuccess];
}

final class HomeFailure extends HomeState {
  final Failure failure;

  const HomeFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}