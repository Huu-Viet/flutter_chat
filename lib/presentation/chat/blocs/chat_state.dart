part of 'chat_bloc.dart';

// Sentinel value to distinguish "not passed" from explicit null in copyWith
const _sentinel = Object();

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
  final Set<String> uploadingVideoPaths;
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
  final bool isLoadingMore;
  final bool hasMoreOld;
  final List<PinMessage> pinnedMessages;
  final Set<String> typingUserIds;
  final Map<String, String> typingUsernames;
  // Jump-to-message fields
  final bool isJumped;
  final bool hasMoreAfter;
  final String? jumpHighlightMessageId;
  final int pendingCount;
  // Poll fields
  final List<PollChatMessage> pollMessages;

  const ChatLoaded(
      this.messages, {
        this.uploadingImagePaths = const <String>{},
        this.uploadingVideoPaths = const <String>{},
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
        this.isLoadingMore = false,
        this.hasMoreOld = true,
        this.pinnedMessages = const <PinMessage>[],
        this.typingUserIds = const <String>{},
        this.typingUsernames = const <String, String>{},
        this.isJumped = false,
        this.hasMoreAfter = false,
        this.jumpHighlightMessageId,
        this.pendingCount = 0,
        this.pollMessages = const <PollChatMessage>[],
      }
  );

  @override
  List<Object> get props => [
    messages,
    uploadingImagePaths,
    uploadingVideoPaths,
    imageUrlsByMediaId,
    audioUrlsByMediaId,
    videoUrlsByMediaId,
    resolvingImageMediaIds,
    resolvingAudioMediaIds,
    resolvingVideoMediaIds,
    if (conversation != null) conversation!,
    if (currentUserId != null) currentUserId!,
    isTyping,
    isLoadingMore,
    hasMoreOld,
    pinnedMessages,
    typingUserIds,
    typingUsernames,
    isJumped,
    hasMoreAfter,
    if (jumpHighlightMessageId != null) jumpHighlightMessageId!,
    pendingCount,
    pollMessages,
  ];

  //copyWith method to update the isTyping status
  ChatLoaded copyWith({
    List<Message>? messages,
    Set<String>? uploadingImagePaths,
    Set<String>? uploadingVideoPaths,
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
    isLoadingMore,
    hasMoreOld,
    List<PinMessage>? pinnedMessages,
    Set<String>? typingUserIds,
    Map<String, String>? typingUsernames,
    bool? isJumped,
    bool? hasMoreAfter,
    Object? jumpHighlightMessageId = _sentinel,
    int? pendingCount,
    List<PollChatMessage>? pollMessages,
  }) {
    return ChatLoaded(
      messages ?? this.messages,
      uploadingImagePaths: uploadingImagePaths ?? this.uploadingImagePaths,
      uploadingVideoPaths: uploadingVideoPaths ?? this.uploadingVideoPaths,
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
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreOld: hasMoreOld ?? this.hasMoreOld,
      pinnedMessages: pinnedMessages ?? this.pinnedMessages,
      typingUserIds: typingUserIds ?? this.typingUserIds,
      typingUsernames: typingUsernames ?? this.typingUsernames,
      isJumped: isJumped ?? this.isJumped,
      hasMoreAfter: hasMoreAfter ?? this.hasMoreAfter,
      jumpHighlightMessageId: jumpHighlightMessageId == _sentinel
          ? this.jumpHighlightMessageId
          : jumpHighlightMessageId as String?,
      pendingCount: pendingCount ?? this.pendingCount,
      pollMessages: pollMessages ?? this.pollMessages,
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