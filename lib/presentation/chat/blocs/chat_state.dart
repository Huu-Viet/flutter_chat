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
  final Set<String> resolvingImageMediaIds;
  final Conversation? conversation;
  final String? currentUserId;

  const ChatLoaded(
    this.messages, {
    this.uploadingImagePaths = const <String>{},
    this.imageUrlsByMediaId = const <String, String>{},
    this.audioUrlsByMediaId = const <String, String>{},
    this.resolvingImageMediaIds = const <String>{},
    this.conversation,
    this.currentUserId,
  });

  @override
  List<Object> get props => [
    messages,
    uploadingImagePaths,
    imageUrlsByMediaId,
    audioUrlsByMediaId,
    resolvingImageMediaIds,
    if (conversation != null) conversation!,
    if (currentUserId != null) currentUserId!,
  ];
}

final class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
