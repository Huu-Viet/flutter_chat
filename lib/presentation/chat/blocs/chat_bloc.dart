import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:uuid/uuid.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessagesUseCase fetchMessagesUseCase;
  final WatchMessagesLocalUseCase watchMessagesLocalUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;

  StreamSubscription<Either<Failure, List<Message>>>? _localSubscription;

  ChatBloc({
    required this.fetchMessagesUseCase,
    required this.watchMessagesLocalUseCase,
    required this.sendMessageUseCase,
    required this.getCurrentUserIdUseCase,
  }) : super(ChatInitial()) {
    on<ChatInitialLoadEvent>(_onChatInitialLoad);
    on<SendTextEvent>(_onSendText);
    on<_LocalMessagesChangedEvent>((event, emit) => emit(ChatLoaded(event.messages)));
    on<_LocalMessagesErrorEvent>((event, emit) => emit(ChatError(event.message)));
  }

  FutureOr<void> _onChatInitialLoad(ChatInitialLoadEvent event, Emitter<ChatState> emit) async {
    _startMessagesLocalWatcher(event.conversationId);
    emit(ChatLoading());
    final result = await fetchMessagesUseCase(event.conversationId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) => emit(ChatLoaded(messages)),
    );
  }

  FutureOr<void> _onSendText(SendTextEvent event, Emitter<ChatState> emit) async {
    final result = await getCurrentUserIdUseCase();
    final userId = result.fold(
      (failure) => null,
      (userId) => userId,
    );
    final messageId = Uuid().v4();
    final message = Message(
      id: messageId,
      conversationId: event.conversationId,
      senderId: userId ?? '',
      content: event.content,
      type: 'text',
      offset: null,
      isDeleted: false,
      mediaId: null,
      serverId: messageId,
      metadata: null,
      createdAt: DateTime.now(),
      editedAt: null,
    );

    unawaited(sendMessageUseCase(message: message));
  }

  void _startMessagesLocalWatcher(String conversationId) {
    _localSubscription?.cancel();
    _localSubscription = watchMessagesLocalUseCase(conversationId).listen((result) {
      result.fold(
        (failure) => add(_LocalMessagesErrorEvent(failure.message)),
        (messages) => add(_LocalMessagesChangedEvent(messages)),
      );
    });
  }
}


