import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchConversationUseCase fetchConversationUseCase;
  final WatchConversationsLocalUseCase watchConversationsLocalUseCase;

  StreamSubscription<Either<Failure, List<Conversation>>>? _localSubscription;
  int _currentPage = 1;
  int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  HomeBloc({
    required this.fetchConversationUseCase,
    required this.watchConversationsLocalUseCase,
  }) : super(HomeInitial()) {
    on<LoadHomeEvent>(_onLoadHome);
    on<LoadMoreHomeEvent>(_onLoadMoreHome);
  }

  Future<void> _onLoadHome(LoadHomeEvent event, Emitter<HomeState> emit) async {
    _currentPage = event.page;
    _limit = event.limit;
    _hasMore = true;
    _isLoadingMore = false;

    emit(HomeLoading());
    await _startLocalWatcher(emit);

    final result = await fetchConversationUseCase(event.page, event.limit);

    result.fold(
      (failure) {
        if (state is! HomeLoaded) {
          emit(HomeFailure(failure));
        }
      },
      (conversations) {
        _hasMore = conversations.length == event.limit && conversations.isNotEmpty;
        if (state is HomeLoading || state is HomeInitial) {
          emit(HomeLoaded(
            conversations: conversations,
            page: _currentPage,
            limit: _limit,
            hasMore: _hasMore,
            isLoadingMore: false,
          ));
          return;
        }

        if (state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(
            page: _currentPage,
            limit: _limit,
            hasMore: _hasMore,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMoreHome(LoadMoreHomeEvent event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) {
      return;
    }

    if (_isLoadingMore || !_hasMore) {
      return;
    }

    _isLoadingMore = true;
    final currentState = state as HomeLoaded;
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = _currentPage + 1;
    final result = await fetchConversationUseCase(nextPage, _limit);

    result.fold(
      (_) {
        _isLoadingMore = false;
        if (state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(isLoadingMore: false));
        }
      },
      (moreConversations) {
        _currentPage = nextPage;
        _hasMore = moreConversations.length == _limit && moreConversations.isNotEmpty;
        _isLoadingMore = false;
        if (state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(
            page: _currentPage,
            hasMore: _hasMore,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  Future<void> _startLocalWatcher(Emitter<HomeState> emit) async {
    await _localSubscription?.cancel();
    _localSubscription = watchConversationsLocalUseCase().listen((result) {
      if (isClosed) {
        return;
      }

      result.fold(
        (failure) {
          if (state is! HomeLoaded) {
            emit(HomeFailure(failure));
          }
        },
        (conversations) {
          emit(HomeLoaded(
            conversations: conversations,
            page: _currentPage,
            limit: _limit,
            hasMore: _hasMore,
            isLoadingMore: _isLoadingMore,
          ));
        },
      );
    });
  }

  @override
  Future<void> close() async {
    await _localSubscription?.cancel();
    return super.close();
  }
}
