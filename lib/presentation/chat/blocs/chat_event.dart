part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();
}

final class ChatInitialLoadEvent extends ChatEvent {
  final String conversationId;

  const ChatInitialLoadEvent(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

final class SendTextEvent extends ChatEvent {
  final String conversationId;
  final String content;

  const SendTextEvent({
    required this.conversationId,
    required this.content,
  });

  @override
  List<Object> get props => [conversationId, content];
}

final class _LocalMessagesErrorEvent extends ChatEvent {
  final String message;

  const _LocalMessagesErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}

final class _LocalMessagesChangedEvent extends ChatEvent {
  final List<Message> messages;

  const _LocalMessagesChangedEvent(this.messages);

  @override
  List<Object> get props => [messages];
}