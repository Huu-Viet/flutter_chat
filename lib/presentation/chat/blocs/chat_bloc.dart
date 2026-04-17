import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessagesUseCase fetchMessagesUseCase;
  final WatchMessagesLocalUseCase watchMessagesLocalUseCase;
  final SendMessageUseCase sendMessageUseCase;

  StreamSubscription<Either<Failure, List<Message>>>? _localSubscription;

  ChatBloc({
    required this.fetchMessagesUseCase,
    required this.watchMessagesLocalUseCase,
    required this.sendMessageUseCase,
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
    final sendResult = await sendMessageUseCase(
      conversationId: event.conversationId,
      content: event.content,
      type: 'text',
    );

    final failure = sendResult.fold<Failure?>(
      (failure) => failure,
      (_) => null,
    );

    if (failure != null) {
      add(_LocalMessagesErrorEvent(failure.message));
      return;
    }

    await fetchMessagesUseCase(event.conversationId, limit: 20);
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


