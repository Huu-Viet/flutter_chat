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
  final String? mediaId;

  const SendTextEvent({
    required this.conversationId,
    required this.content,
    this.mediaId,
  });

  @override
  List<Object> get props => [conversationId, content, ?mediaId];
}

final class SendImageEvent extends ChatEvent {
  final String conversationId;
  final String imagePath;
  final int imageSize;

  const SendImageEvent({
    required this.conversationId,
    required this.imagePath,
    required this.imageSize,
  });

  @override
  List<Object> get props => [conversationId, imagePath, imageSize];
}

final class SendStickerEvent extends ChatEvent {
  final String conversationId;
  final String stickerId;
  final String stickerUrl;

  const SendStickerEvent({
    required this.conversationId,
    required this.stickerId,
    required this.stickerUrl,
  });

  @override
  List<Object> get props => [conversationId, stickerId, stickerUrl];
}

final class FetchImageEvent extends ChatEvent {
  final String mediaId;

  const FetchImageEvent(this.mediaId);

  @override
  List<Object> get props => [mediaId];
}

final class EditMessageEvent extends ChatEvent {
  final String localId;
  final String messageId;
  final String content;

  const EditMessageEvent({
    required this.localId,
    required this.messageId,
    required this.content,
  });

  @override
  List<Object> get props => [localId, messageId, content];
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

final class _LocalConversationChangedEvent extends ChatEvent {
  final Conversation conversation;

  const _LocalConversationChangedEvent(this.conversation);

  @override
  List<Object> get props => [conversation];
}