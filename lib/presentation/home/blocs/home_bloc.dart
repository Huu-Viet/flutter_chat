import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/features/friendship/export.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchConversationUseCase fetchConversationUseCase;
  final WatchConversationsLocalUseCase watchConversationsLocalUseCase;
  final SyncFriendshipsToLocalUseCase syncFriendshipsToLocalUseCase;
  final JoinConversationUseCase joinConversationUseCase;

  StreamSubscription<Either<Failure, List<Conversation>>>? _localSubscription;
  int _currentPage = 1;
  int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  HomeBloc({
    required this.fetchConversationUseCase,
    required this.watchConversationsLocalUseCase,
    required this.syncFriendshipsToLocalUseCase,
    required this.joinConversationUseCase,
  }) : super(HomeInitial()) {
    on<InitialLoadHomeEvent>(_onInitialLoadHome);
    on<LoadHomeEvent>(_onLoadHome);
    on<LoadMoreHomeEvent>(_onLoadMoreHome);
    on<JoinConversationEvent>(_onJoinConversation);
    on<_LocalConversationsChangedEvent>(_onLocalConversationsChanged);
    on<_LocalConversationsErrorEvent>(_onLocalConversationsError);
  }

  Future<void> _onInitialLoadHome(
    InitialLoadHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeInitial) {
      emit(HomeLoaded(
        conversations: const <Conversation>[],
        page: _currentPage,
        limit: _limit,
        hasMore: _hasMore,
        isLoadingMore: false,
      ));
    }

    _startLocalWatcher(emit);

    final syncResult = await syncFriendshipsToLocalUseCase();
    syncResult.fold(
      (failure) => debugPrint('[HomeBloc] sync friendships failed: ${failure.message}'),
      (_) => debugPrint('[HomeBloc] synced friendships to local'),
    );
  }

  Future<void> _onLoadHome(LoadHomeEvent event, Emitter<HomeState> emit) async {
    _currentPage = event.page;
    _limit = event.limit;
    _hasMore = true;
    _isLoadingMore = false;

    final result = await fetchConversationUseCase(event.page, event.limit);

    result.fold(
      (failure) {
        if (state is! HomeLoaded) {
          emit(HomeFailure(failure));
        }
      },
      (hasMore) {
        _hasMore = hasMore;
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
      (failure) {
        debugPrint('[HomeBloc] load more failed: ${failure.message}');
        _isLoadingMore = false;
        if (state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(isLoadingMore: false));
        }
      },
      (hasMore) {
        _currentPage = nextPage;
        _hasMore = hasMore;
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

  void _startLocalWatcher(Emitter<HomeState> emit) {
    _localSubscription?.cancel();
    _localSubscription = watchConversationsLocalUseCase().listen((result) {
      if (isClosed) {
        return;
      }

      result.fold(
        (failure) => add(_LocalConversationsErrorEvent(failure)),
        (conversations) {
          add(_LocalConversationsChangedEvent(conversations));
        },
      );
    });
  }

  void _onLocalConversationsChanged(
    _LocalConversationsChangedEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeLoaded(
      conversations: event.conversations,
      page: _currentPage,
      limit: _limit,
      hasMore: _hasMore,
      isLoadingMore: _isLoadingMore,
    ));
  }

  void _onLocalConversationsError(
    _LocalConversationsErrorEvent event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoaded) {
      emit(HomeFailure(event.failure));
    }
  }

  @override
  Future<void> close() async {
    await _localSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onJoinConversation(JoinConversationEvent event, Emitter<HomeState> emit) async {
    final result = await joinConversationUseCase(event.conversationId);
    result.fold(
      (failure) => debugPrint('[HomeBloc] failed to join conversation: ${failure.message}'),
      (_) => debugPrint('[HomeBloc] joined conversation')
    );
  }
}
