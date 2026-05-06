import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/features/friendship/export.dart';
import 'package:flutter_chat/features/group_manager/domain/usecase/create_group_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchConversationUseCase fetchConversationUseCase;
  final WatchConversationsLocalUseCase watchConversationsLocalUseCase;
  final SyncFriendshipsToLocalUseCase syncFriendshipsToLocalUseCase;
  final JoinConversationUseCase joinConversationUseCase;
  final CreateGroupUseCase createGroupUseCase;
  final UpdateConversationLastMessageLocalUseCase
  updateConversationLastMessageLocalUseCase;
  final RealtimeGateway realtimeGateway;

  StreamSubscription<Either<Failure, List<Conversation>>>? _localSubscription;
  StreamSubscription<RealtimeGatewayEvent>? _realtimeSubscription;
  int _currentPage = 1;
  int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  HomeBloc({
    required this.fetchConversationUseCase,
    required this.watchConversationsLocalUseCase,
    required this.syncFriendshipsToLocalUseCase,
    required this.joinConversationUseCase,
    required this.createGroupUseCase,
    required this.updateConversationLastMessageLocalUseCase,
    required this.realtimeGateway,
  }) : super(HomeInitial()) {
    on<InitialLoadHomeEvent>(_onInitialLoadHome);
    on<LoadHomeEvent>(_onLoadHome);
    on<LoadMoreHomeEvent>(_onLoadMoreHome);
    on<JoinConversationEvent>(_onJoinConversation);
    on<_LocalConversationsChangedEvent>(_onLocalConversationsChanged);
    on<_LocalConversationsErrorEvent>(_onLocalConversationsError);
    on<_RealtimeMessageNewEvent>(_onRealtimeMessageNew);
    on<CreateGroupEvent>(_createGroup);
  }

  Future<void> _onInitialLoadHome(
    InitialLoadHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeInitial) {
      emit(
        HomeLoaded(
          conversations: const <Conversation>[],
          page: _currentPage,
          limit: _limit,
          hasMore: _hasMore,
          isLoadingMore: false,
        ),
      );
    }

    _startLocalWatcher(emit);
    _startRealtimeWatcher();

    final syncResult = await syncFriendshipsToLocalUseCase();
    syncResult.fold(
      (failure) =>
          debugPrint('[HomeBloc] sync friendships failed: ${failure.message}'),
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
          emit(
            (state as HomeLoaded).copyWith(
              page: _currentPage,
              limit: _limit,
              hasMore: _hasMore,
              isLoadingMore: false,
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadMoreHome(
    LoadMoreHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
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
          emit(
            (state as HomeLoaded).copyWith(
              page: _currentPage,
              hasMore: _hasMore,
              isLoadingMore: false,
            ),
          );
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

      result.fold((failure) => add(_LocalConversationsErrorEvent(failure)), (
        conversations,
      ) {
        add(_LocalConversationsChangedEvent(conversations));
      });
    });
  }

  void _startRealtimeWatcher() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = realtimeGateway.events.listen((event) {
      if (isClosed ||
          event.namespace != '/chat' ||
          event.event != 'message:new') {
        return;
      }

      final payload = event.payload;
      if (payload is Map<String, dynamic>) {
        add(_RealtimeMessageNewEvent(payload));
      } else if (payload is Map) {
        add(_RealtimeMessageNewEvent(_toStringKeyedMap(payload)));
      }
    });
  }

  void _onLocalConversationsChanged(
    _LocalConversationsChangedEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(
      HomeLoaded(
        conversations: event.conversations,
        page: _currentPage,
        limit: _limit,
        hasMore: _hasMore,
        isLoadingMore: _isLoadingMore,
      ),
    );
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
    await _realtimeSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRealtimeMessageNew(
    _RealtimeMessageNewEvent event,
    Emitter<HomeState> emit,
  ) async {
    final messageMap = _resolveMessagePayload(event.payload);
    final conversationId = _resolveConversationId(event.payload, messageMap);
    if (conversationId == null || conversationId.isEmpty) {
      return;
    }

    final messageId =
        _readString(messageMap['id']) ??
        _readString(messageMap['messageId']) ??
        _readString(messageMap['clientMessageId']);
    if (messageId == null || messageId.isEmpty) {
      return;
    }

    final createdAt =
        DateTime.tryParse(
          _readString(messageMap['createdAt']) ??
              _readString(messageMap['created_at']) ??
              _readString(messageMap['timestamp']) ??
              '',
        ) ??
        DateTime.now();
    final lastMessage = ConversationLastMessage(
      id: messageId,
      content: _readString(messageMap['content']) ?? '',
      type: (_readString(messageMap['type']) ?? 'text').toLowerCase(),
      offset: _readInt(messageMap['offset']),
      senderId:
          _readString(messageMap['senderId']) ??
          _readString(messageMap['sender_id']) ??
          '',
      isDeleted:
          _readBool(messageMap['isDeleted']) ??
          _readBool(messageMap['is_deleted']) ??
          false,
      isRevoked:
          _readBool(messageMap['isRevoked']) ??
          _readBool(messageMap['is_revoked']) ??
          false,
      createdAt: createdAt,
    );

    final result = await updateConversationLastMessageLocalUseCase(
      conversationId: conversationId,
      lastMessage: lastMessage,
    );
    result.fold(
      (failure) => debugPrint(
        '[HomeBloc] failed to update realtime last message: ${failure.message}',
      ),
      (_) => debugPrint(
        '[HomeBloc] updated realtime last message: conversationId=$conversationId',
      ),
    );
  }

  Map<String, dynamic> _resolveMessagePayload(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is Map) {
      final dataMap = _toStringKeyedMap(data);
      final dataMessage = dataMap['message'];
      if (dataMessage is Map) {
        return _toStringKeyedMap(dataMessage);
      }
      if (dataMap.containsKey('conversationId') && dataMap.containsKey('id')) {
        return dataMap;
      }
    }

    final message = payload['message'];
    if (message is Map) {
      return _toStringKeyedMap(message);
    }

    return payload;
  }

  String? _resolveConversationId(
    Map<String, dynamic> payload,
    Map<String, dynamic> messageMap,
  ) {
    final direct =
        _readString(messageMap['conversationId']) ??
        _readString(messageMap['conversation_id']) ??
        _readString(payload['conversationId']) ??
        _readString(payload['conversation_id']);
    if (direct != null) {
      return direct;
    }

    final data = payload['data'];
    if (data is Map) {
      final dataMap = _toStringKeyedMap(data);
      final nested =
          _readString(dataMap['conversationId']) ??
          _readString(dataMap['conversation_id']);
      if (nested != null) {
        return nested;
      }
    }

    return null;
  }

  Map<String, dynamic> _toStringKeyedMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) => MapEntry(key.toString(), value));
  }

  String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  FutureOr<void> _onJoinConversation(
    JoinConversationEvent event,
    Emitter<HomeState> emit,
  ) async {
    final result = await joinConversationUseCase(event.conversationId);
    result.fold(
      (failure) => debugPrint(
        '[HomeBloc] failed to join conversation: ${failure.message}',
      ),
      (_) => debugPrint('[HomeBloc] joined conversation'),
    );
  }

  Future<void> _createGroup(
    CreateGroupEvent event,
    Emitter<HomeState> emit,
  ) async {
    final createResult = await createGroupUseCase(
      type: "group",
      memberIds: event.memberIds,
      groupName: event.name,
      description: event.description,
      mediaId: event.mediaId,
    );

    await createResult.fold(
      (failure) async {
        debugPrint('[HomeBloc] failed to create group: ${failure.message}');
        if (state is! HomeLoaded) {
          emit(HomeFailure(failure));
        }
      },
      (_) async {
        _currentPage = 1;
        final fetchResult = await fetchConversationUseCase(
          _currentPage,
          _limit,
        );

        fetchResult.fold(
          (failure) {
            if (state is! HomeLoaded) {
              emit(HomeFailure(failure));
            }
          },
          (hasMore) {
            _hasMore = hasMore;
            if (state is HomeLoaded) {
              emit(
                (state as HomeLoaded).copyWith(
                  page: _currentPage,
                  limit: _limit,
                  hasMore: _hasMore,
                  isLoadingMore: false,
                ),
              );
            }
          },
        );
      },
    );
  }
}
