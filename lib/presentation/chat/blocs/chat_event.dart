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
  final String? replyToMessageId;
  final List<String> mentions;

  const SendTextEvent({
    required this.conversationId,
    required this.content,
    this.mediaId,
    this.replyToMessageId,
    this.mentions = const <String>[],
  });

  @override
  List<Object?> get props => [conversationId, content, mediaId, replyToMessageId, mentions];
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

final class SendFileEvent extends ChatEvent {
  final String conversationId;
  final String filePath;
  final String fileName;
  final int fileSize;

  const SendFileEvent({
    required this.conversationId,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
  });

  @override
  List<Object> get props => [conversationId, filePath, fileName, fileSize];
}

final class SendVideoEvent extends ChatEvent {
  final String conversationId;
  final File file;

  const SendVideoEvent({
    required this.conversationId,
    required this.file,
  });

  @override
  List<Object> get props => [conversationId, file];
}

final class GetFileDownloadUrlEvent extends ChatEvent {
  final String mediaId;
  final String fileName;

  const GetFileDownloadUrlEvent({
    required this.mediaId,
    required this.fileName,
  });

  @override
  List<Object> get props => [mediaId, fileName];
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

final class SendAudioEvent extends ChatEvent {
  final String conversationId;
  final String audioPath;
  final int durationMs;
  final List<double> waveform;

  const SendAudioEvent({
    required this.conversationId,
    required this.audioPath,
    required this.durationMs,
    required this.waveform,
  });

  @override
  List<Object> get props => [conversationId, audioPath, durationMs, waveform];
}

final class FetchImageEvent extends ChatEvent {
  final String mediaId;

  const FetchImageEvent(this.mediaId);

  @override
  List<Object> get props => [mediaId];
}

final class FetchAudioEvent extends ChatEvent {
  final String mediaId;
  final String conversationId;

  const FetchAudioEvent({
    required this.mediaId,
    required this.conversationId,
  });

  @override
  List<Object> get props => [mediaId, conversationId];
}

final class FetchVideoEvent extends ChatEvent {
  final String mediaId;
  final String conversationId;

  const FetchVideoEvent({
    required this.mediaId,
    required this.conversationId,
  });

  @override
  List<Object> get props => [mediaId, conversationId];
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

final class HiddenMessageEvent extends ChatEvent {
  final String localId;
  final String messageId;
  final String conversationId;

  const HiddenMessageEvent({
    required this.localId,
    required this.messageId,
    required this.conversationId,
  });

  @override
  List<Object> get props => [localId, messageId, conversationId];
}

final class RevokeMessageEvent extends ChatEvent {
  final String localId;
  final String messageId;
  final String conversationId;

  const RevokeMessageEvent({
    required this.localId,
    required this.messageId,
    required this.conversationId,
  });

  @override
  List<Object> get props => [localId, messageId, conversationId];
}

final class UpdateMessageReactionEvent extends ChatEvent {
  final String messageId;
  final String conversationId;
  final String emoji;
  final String action;

  const UpdateMessageReactionEvent({
    required this.messageId,
    required this.conversationId,
    required this.emoji,
    this.action = 'add',
  });

  @override
  List<Object> get props => [messageId, conversationId, emoji, action];
}

final class ForwardMessageEvent extends ChatEvent {
  final String messageId;
  final String srcConversationId;
  final List<String> targetConversationIds;

  const ForwardMessageEvent({
    required this.messageId,
    required this.srcConversationId,
    required this.targetConversationIds,
  });

  @override
  List<Object> get props => [messageId, srcConversationId, targetConversationIds];
}

final class EmitTypingEvent extends ChatEvent {
  final String conversationId;
  final bool isTyping;

  const EmitTypingEvent(this.conversationId, this.isTyping);

  @override
  List<Object> get props => [conversationId, isTyping];
}

final class TypingChangedEvent extends ChatEvent {
  final String conversationId;
  final String userId;
  final String? username;
  final bool isTyping;

  const TypingChangedEvent({
    required this.conversationId,
    required this.userId,
    this.username,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [conversationId, userId, username, isTyping];
}

final class _LocalMessagesErrorEvent extends ChatEvent {
  final String message;

  const _LocalMessagesErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}

final class LoadMoreMessagesEvent extends ChatEvent {
  final String conversationId;

  const LoadMoreMessagesEvent(this.conversationId);

  @override
  List<Object> get props => [conversationId];
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

final class _LocalPinnedMessagesChangedEvent extends ChatEvent {
  final List<PinMessage> pinnedMessages;

  const _LocalPinnedMessagesChangedEvent(this.pinnedMessages);

  @override
  List<Object> get props => [pinnedMessages];
}