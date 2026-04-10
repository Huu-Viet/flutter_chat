import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchConversationUseCase fetchConversationUseCase;

  HomeBloc({
    required this.fetchConversationUseCase,
  }) : super(HomeInitial()) {
    on<LoadHomeEvent>(_onLoadHome);
    on<LoadMoreHomeEvent>(_onLoadMoreHome);
  }

  Future<void> _onLoadHome(LoadHomeEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    final result = await fetchConversationUseCase(event.page, event.limit);

    result.fold(
      (failure) => emit(HomeFailure(failure)),
      (conversations) => emit(
        HomeLoaded(
          conversations: conversations,
          page: event.page,
          limit: event.limit,
          hasMore: conversations.length == event.limit && conversations.isNotEmpty,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreHome(LoadMoreHomeEvent event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is! HomeLoaded) {
      return;
    }

    if (currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.page + 1;
    final result = await fetchConversationUseCase(nextPage, currentState.limit);

    result.fold(
      (_) => emit(currentState.copyWith(isLoadingMore: false)),
      (moreConversations) {
        emit(
          currentState.copyWith(
            conversations: [...currentState.conversations, ...moreConversations],
            page: nextPage,
            hasMore: moreConversations.length == currentState.limit &&
                moreConversations.isNotEmpty,
            isLoadingMore: false,
          ),
        );
      },
    );
  }
}
