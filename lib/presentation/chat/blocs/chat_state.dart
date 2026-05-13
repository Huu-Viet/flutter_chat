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

final class ChatMessageState extends Equatable {
  final List<Message> messages;
  final bool isLoadingMore;
  final bool hasMoreOld;
  final List<PinMessage> pinnedMessages;

  const ChatMessageState({
    this.messages = const <Message>[],
    this.isLoadingMore = false,
    this.hasMoreOld = true,
    this.pinnedMessages = const <PinMessage>[],
  });

  ChatMessageState copyWith({
    List<Message>? messages,
    bool? isLoadingMore,
    bool? hasMoreOld,
    List<PinMessage>? pinnedMessages,
  }) {
    return ChatMessageState(
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreOld: hasMoreOld ?? this.hasMoreOld,
      pinnedMessages: pinnedMessages ?? this.pinnedMessages,
    );
  }

  @override
  List<Object> get props => [
    messages,
    isLoadingMore,
    hasMoreOld,
    pinnedMessages,
  ];
}

final class ChatMediaState extends Equatable {
  final Set<String> uploadingImagePaths;
  final Set<String> uploadingFilePaths;
  final Set<String> uploadingVideoPaths;
  final Map<String, String> imageUrlsByMediaId;
  final Map<String, String> audioUrlsByMediaId;
  final Map<String, String> videoUrlsByMediaId;
  final Map<String, String> fileUrlsByMediaId;
  final Set<String> resolvingImageMediaIds;
  final Set<String> resolvingAudioMediaIds;
  final Set<String> resolvingVideoMediaIds;
  final Set<String> resolvingFileMediaIds;

  const ChatMediaState({
    this.uploadingImagePaths = const <String>{},
    this.uploadingFilePaths = const <String>{},
    this.uploadingVideoPaths = const <String>{},
    this.imageUrlsByMediaId = const <String, String>{},
    this.audioUrlsByMediaId = const <String, String>{},
    this.videoUrlsByMediaId = const <String, String>{},
    this.fileUrlsByMediaId = const <String, String>{},
    this.resolvingImageMediaIds = const <String>{},
    this.resolvingAudioMediaIds = const <String>{},
    this.resolvingVideoMediaIds = const <String>{},
    this.resolvingFileMediaIds = const <String>{},
  });

  ChatMediaState copyWith({
    Set<String>? uploadingImagePaths,
    Set<String>? uploadingFilePaths,
    Set<String>? uploadingVideoPaths,
    Map<String, String>? imageUrlsByMediaId,
    Map<String, String>? audioUrlsByMediaId,
    Map<String, String>? videoUrlsByMediaId,
    Map<String, String>? fileUrlsByMediaId,
    Set<String>? resolvingImageMediaIds,
    Set<String>? resolvingAudioMediaIds,
    Set<String>? resolvingVideoMediaIds,
    Set<String>? resolvingFileMediaIds,
  }) {
    return ChatMediaState(
      uploadingImagePaths: uploadingImagePaths ?? this.uploadingImagePaths,
      uploadingFilePaths: uploadingFilePaths ?? this.uploadingFilePaths,
      uploadingVideoPaths: uploadingVideoPaths ?? this.uploadingVideoPaths,
      imageUrlsByMediaId: imageUrlsByMediaId ?? this.imageUrlsByMediaId,
      audioUrlsByMediaId: audioUrlsByMediaId ?? this.audioUrlsByMediaId,
      videoUrlsByMediaId: videoUrlsByMediaId ?? this.videoUrlsByMediaId,
      fileUrlsByMediaId: fileUrlsByMediaId ?? this.fileUrlsByMediaId,
      resolvingImageMediaIds:
          resolvingImageMediaIds ?? this.resolvingImageMediaIds,
      resolvingAudioMediaIds:
          resolvingAudioMediaIds ?? this.resolvingAudioMediaIds,
      resolvingVideoMediaIds:
          resolvingVideoMediaIds ?? this.resolvingVideoMediaIds,
      resolvingFileMediaIds:
          resolvingFileMediaIds ?? this.resolvingFileMediaIds,
    );
  }

  @override
  List<Object> get props => [
    uploadingImagePaths,
    uploadingFilePaths,
    uploadingVideoPaths,
    imageUrlsByMediaId,
    audioUrlsByMediaId,
    videoUrlsByMediaId,
    fileUrlsByMediaId,
    resolvingImageMediaIds,
    resolvingAudioMediaIds,
    resolvingVideoMediaIds,
    resolvingFileMediaIds,
  ];
}

enum FriendshipActionType {
  sendRequest,
  acceptRequest,
  cancelRequest,
  block,
  unblock,
}

final class FriendshipActionFeedback extends Equatable {
  final String targetUserId;
  final FriendshipActionType actionType;
  final bool isSuccess;
  final String? failureMessage;

  const FriendshipActionFeedback({
    required this.targetUserId,
    required this.actionType,
    required this.isSuccess,
    this.failureMessage,
  });

  @override
  List<Object?> get props => [
    targetUserId,
    actionType,
    isSuccess,
    failureMessage,
  ];
}

final class ChatConversationState extends Equatable {
  final Conversation? conversation;
  final String? currentUserId;
  final bool isTyping;
  final Set<String> typingUserIds;
  final Map<String, String> typingUsernames;
  final Set<String> friendshipActionInProgressUserIds;
  final FriendshipActionFeedback? friendshipActionFeedback;

  const ChatConversationState({
    this.conversation,
    this.currentUserId,
    this.isTyping = false,
    this.typingUserIds = const <String>{},
    this.typingUsernames = const <String, String>{},
    this.friendshipActionInProgressUserIds = const <String>{},
    this.friendshipActionFeedback,
  });

  ChatConversationState copyWith({
    Conversation? conversation,
    String? currentUserId,
    bool? isTyping,
    Set<String>? typingUserIds,
    Map<String, String>? typingUsernames,
    Set<String>? friendshipActionInProgressUserIds,
    Object? friendshipActionFeedback = _sentinel,
  }) {
    return ChatConversationState(
      conversation: conversation ?? this.conversation,
      currentUserId: currentUserId ?? this.currentUserId,
      isTyping: isTyping ?? this.isTyping,
      typingUserIds: typingUserIds ?? this.typingUserIds,
      typingUsernames: typingUsernames ?? this.typingUsernames,
      friendshipActionInProgressUserIds: friendshipActionInProgressUserIds ??
          this.friendshipActionInProgressUserIds,
      friendshipActionFeedback: friendshipActionFeedback == _sentinel
          ? this.friendshipActionFeedback
          : friendshipActionFeedback as FriendshipActionFeedback?,
    );
  }

  @override
  List<Object> get props => [
    if (conversation != null) conversation!,
    if (currentUserId != null) currentUserId!,
    isTyping,
    typingUserIds,
    typingUsernames,
    friendshipActionInProgressUserIds,
    if (friendshipActionFeedback != null) friendshipActionFeedback!,
  ];
}

final class ChatJumpState extends Equatable {
  final bool isJumped;
  final bool hasMoreAfter;
  final String? jumpHighlightMessageId;
  final int pendingCount;

  const ChatJumpState({
    this.isJumped = false,
    this.hasMoreAfter = false,
    this.jumpHighlightMessageId,
    this.pendingCount = 0,
  });

  ChatJumpState copyWith({
    bool? isJumped,
    bool? hasMoreAfter,
    Object? jumpHighlightMessageId = _sentinel,
    int? pendingCount,
  }) {
    return ChatJumpState(
      isJumped: isJumped ?? this.isJumped,
      hasMoreAfter: hasMoreAfter ?? this.hasMoreAfter,
      jumpHighlightMessageId: jumpHighlightMessageId == _sentinel
          ? this.jumpHighlightMessageId
          : jumpHighlightMessageId as String?,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  @override
  List<Object> get props => [
    isJumped,
    hasMoreAfter,
    if (jumpHighlightMessageId != null) jumpHighlightMessageId!,
    pendingCount,
  ];
}

final class ChatPollState extends Equatable {
  final List<PollChatMessage> pollMessages;

  const ChatPollState({this.pollMessages = const <PollChatMessage>[]});

  ChatPollState copyWith({List<PollChatMessage>? pollMessages}) {
    return ChatPollState(pollMessages: pollMessages ?? this.pollMessages);
  }

  @override
  List<Object> get props => [pollMessages];
}

final class ChatLoaded extends ChatState {
  final ChatMessageState messageState;
  final ChatMediaState mediaState;
  final ChatConversationState conversationState;
  final ChatJumpState jumpState;
  final ChatPollState pollState;

  const ChatLoaded({
    required this.messageState,
    this.mediaState = const ChatMediaState(),
    this.conversationState = const ChatConversationState(),
    this.jumpState = const ChatJumpState(),
    this.pollState = const ChatPollState(),
  });

  List<Message> get messages => messageState.messages;
  bool get isLoadingMore => messageState.isLoadingMore;
  bool get hasMoreOld => messageState.hasMoreOld;
  List<PinMessage> get pinnedMessages => messageState.pinnedMessages;

  Set<String> get uploadingImagePaths => mediaState.uploadingImagePaths;
  Set<String> get uploadingFilePaths => mediaState.uploadingFilePaths;
  Set<String> get uploadingVideoPaths => mediaState.uploadingVideoPaths;
  Map<String, String> get imageUrlsByMediaId => mediaState.imageUrlsByMediaId;
  Map<String, String> get audioUrlsByMediaId => mediaState.audioUrlsByMediaId;
  Map<String, String> get videoUrlsByMediaId => mediaState.videoUrlsByMediaId;
  Map<String, String> get fileUrlsByMediaId => mediaState.fileUrlsByMediaId;
  Set<String> get resolvingImageMediaIds => mediaState.resolvingImageMediaIds;
  Set<String> get resolvingAudioMediaIds => mediaState.resolvingAudioMediaIds;
  Set<String> get resolvingVideoMediaIds => mediaState.resolvingVideoMediaIds;
  Set<String> get resolvingFileMediaIds => mediaState.resolvingFileMediaIds;

  Conversation? get conversation => conversationState.conversation;
  String? get currentUserId => conversationState.currentUserId;
  bool get isTyping => conversationState.isTyping;
  Set<String> get typingUserIds => conversationState.typingUserIds;
  Map<String, String> get typingUsernames =>
      conversationState.typingUsernames;
    Set<String> get friendshipActionInProgressUserIds =>
      conversationState.friendshipActionInProgressUserIds;
    FriendshipActionFeedback? get friendshipActionFeedback =>
      conversationState.friendshipActionFeedback;

  bool get isJumped => jumpState.isJumped;
  bool get hasMoreAfter => jumpState.hasMoreAfter;
  String? get jumpHighlightMessageId => jumpState.jumpHighlightMessageId;
  int get pendingCount => jumpState.pendingCount;

  List<PollChatMessage> get pollMessages => pollState.pollMessages;

  @override
  List<Object> get props => [
    messageState,
    mediaState,
    conversationState,
    jumpState,
    pollState,
  ];

  ChatLoaded copyWith({
    ChatMessageState? messageState,
    ChatMediaState? mediaState,
    ChatConversationState? conversationState,
    ChatJumpState? jumpState,
    ChatPollState? pollState,
    List<Message>? messages,
    Set<String>? uploadingImagePaths,
    Set<String>? uploadingFilePaths,
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
    Set<String>? friendshipActionInProgressUserIds,
    Object? friendshipActionFeedback = _sentinel,
    bool? isJumped,
    bool? hasMoreAfter,
    Object? jumpHighlightMessageId = _sentinel,
    int? pendingCount,
    List<PollChatMessage>? pollMessages,
  }) {
    return ChatLoaded(
      messageState:
          messageState ?? this.messageState.copyWith(
            messages: messages,
            isLoadingMore: isLoadingMore,
            hasMoreOld: hasMoreOld,
            pinnedMessages: pinnedMessages,
          ),
      mediaState:
          mediaState ?? this.mediaState.copyWith(
            uploadingImagePaths: uploadingImagePaths,
            uploadingFilePaths: uploadingFilePaths,
            uploadingVideoPaths: uploadingVideoPaths,
            imageUrlsByMediaId: imageUrlsByMediaId,
            audioUrlsByMediaId: audioUrlsByMediaId,
            videoUrlsByMediaId: videoUrlsByMediaId,
            fileUrlsByMediaId: fileUrlsByMediaId,
            resolvingImageMediaIds: resolvingImageMediaIds,
            resolvingAudioMediaIds: resolvingAudioMediaIds,
            resolvingVideoMediaIds: resolvingVideoMediaIds,
            resolvingFileMediaIds: resolvingFileMediaIds,
          ),
      conversationState:
          conversationState ?? this.conversationState.copyWith(
            conversation: conversation,
            currentUserId: currentUserId,
            isTyping: isTyping,
            typingUserIds: typingUserIds,
            typingUsernames: typingUsernames,
            friendshipActionInProgressUserIds:
                friendshipActionInProgressUserIds,
            friendshipActionFeedback: friendshipActionFeedback,
          ),
      jumpState:
          jumpState ?? this.jumpState.copyWith(
            isJumped: isJumped,
            hasMoreAfter: hasMoreAfter,
            jumpHighlightMessageId: jumpHighlightMessageId,
            pendingCount: pendingCount,
          ),
      pollState: pollState ?? this.pollState.copyWith(pollMessages: pollMessages),
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