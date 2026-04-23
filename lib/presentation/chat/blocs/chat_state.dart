part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatLoaded extends ChatState {
  final List<Message> messages;
  final Set<String> uploadingImagePaths;
  final Map<String, String> imageUrlsByMediaId;
  final Map<String, String> audioUrlsByMediaId;
  final Map<String, String> videoUrlsByMediaId;
  final Map<String, String> fileUrlsByMediaId;
  final Set<String> resolvingImageMediaIds;
  final Set<String> resolvingAudioMediaIds;
  final Set<String> resolvingVideoMediaIds;
  final Set<String> resolvingFileMediaIds;
  final Conversation? conversation;
  final String? currentUserId;
  final bool isTyping;
  final Set<String> typingUserIds;
  final Map<String, String> typingUsernames;

  const ChatLoaded(
    this.messages, {
    this.uploadingImagePaths = const <String>{},
    this.imageUrlsByMediaId = const <String, String>{},
    this.audioUrlsByMediaId = const <String, String>{},
    this.videoUrlsByMediaId = const <String, String>{},
    this.fileUrlsByMediaId = const <String, String>{},
    this.resolvingImageMediaIds = const <String>{},
    this.resolvingAudioMediaIds = const <String>{},
    this.resolvingVideoMediaIds = const <String>{},
    this.resolvingFileMediaIds = const <String>{},
    this.conversation,
    this.currentUserId,
    this.isTyping = false,
    this.typingUserIds = const <String>{},
    this.typingUsernames = const <String, String>{},
  });

  @override
  List<Object> get props => [
    messages,
    uploadingImagePaths,
    imageUrlsByMediaId,
    audioUrlsByMediaId,
    videoUrlsByMediaId,
    resolvingImageMediaIds,
    resolvingAudioMediaIds,
    resolvingVideoMediaIds,
    if (conversation != null) conversation!,
    if (currentUserId != null) currentUserId!,
    isTyping,
    typingUserIds,
    typingUsernames,
  ];

  //copyWith method to update the isTyping status
  ChatLoaded copyWith({
    List<Message>? messages,
    Set<String>? uploadingImagePaths,
    Map<String, String>? imageUrlsByMediaId,
    Map<String, String>? audioUrlsByMediaId,
    Map<String, String>? videoUrlsByMediaId,
    Map<String, String>? fileUrlsByMediaId,
    Set<String>? resolvingImageMediaIds,
    Set<String>? resolvingAudioMediaIds,
    Set<String>? resolvingVideoMediaIds,
    Set<String>? resolvingFileMediaIds,
    Conversation? conversation,
    String? currentUserId,
    bool? isTyping,
    Set<String>? typingUserIds,
    Map<String, String>? typingUsernames,
  }) {
    return ChatLoaded(
      messages ?? this.messages,
      uploadingImagePaths: uploadingImagePaths ?? this.uploadingImagePaths,
      imageUrlsByMediaId: imageUrlsByMediaId ?? this.imageUrlsByMediaId,
      audioUrlsByMediaId: audioUrlsByMediaId ?? this.audioUrlsByMediaId,
      videoUrlsByMediaId: videoUrlsByMediaId ?? this.videoUrlsByMediaId,
      fileUrlsByMediaId: fileUrlsByMediaId ?? this.fileUrlsByMediaId,
      resolvingImageMediaIds: resolvingImageMediaIds ??
          this.resolvingImageMediaIds,
      resolvingAudioMediaIds: resolvingAudioMediaIds ??
          this.resolvingAudioMediaIds,
      resolvingVideoMediaIds: resolvingVideoMediaIds ??
          this.resolvingVideoMediaIds,
      resolvingFileMediaIds: resolvingFileMediaIds ??
          this.resolvingFileMediaIds,
      conversation: conversation ?? this.conversation,
      currentUserId: currentUserId ?? this.currentUserId,
      isTyping: isTyping ?? this.isTyping,
      typingUserIds: typingUserIds ?? this.typingUserIds,
      typingUsernames: typingUsernames ?? this.typingUsernames,
    );
  }
}

final class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

final class ForwardingMessages extends ChatState {}

final class ForwardMessagesError extends ChatState {
  final String message;

  const ForwardMessagesError(this.message);

  @override
  List<Object> get props => [message];
}

final class ForwardMessagesSuccess extends ChatState {}