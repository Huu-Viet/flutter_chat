import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/features/upload_media/export.dart';
import 'package:flutter_chat/presentation/chat/chat_image_cache_manager.dart';
import 'package:uuid/uuid.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessagesUseCase fetchMessagesUseCase;
  final WatchMessagesLocalUseCase watchMessagesLocalUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final EditMessageUseCase editMessageUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;
  final UpdateMessageReactionUseCase updateMessageReactionUseCase;
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;
  final UploadMediaUseCase uploadMediaUseCase;
  final GetImageUrlByMediaIdUseCase getImageUrlByMediaIdUseCase;
  final WatchConversationsLocalUseCase watchConversationsLocalUseCase;
  String? _currentUserId;

  StreamSubscription<Either<Failure, List<Message>>>? _localSubscription;
  StreamSubscription<Either<Failure, List<Conversation>>>? _conversationSubscription;
  List<Message> _currentMessages = const [];
  Conversation? _currentConversation;
  final Set<String> _uploadingImagePaths = <String>{};
  final Map<String, String> _imageUrlsByMediaId = <String, String>{};
  final Set<String> _resolvingImageMediaIds = <String>{};

  ChatBloc({
    required this.fetchMessagesUseCase,
    required this.watchMessagesLocalUseCase,
    required this.sendMessageUseCase,
    required this.editMessageUseCase,
    required this.deleteMessageUseCase,
    required this.updateMessageReactionUseCase,
    required this.getCurrentUserIdUseCase,
    required this.uploadMediaUseCase,
    required this.getImageUrlByMediaIdUseCase,
    required this.watchConversationsLocalUseCase,
  }) : super(ChatInitial()) {
    on<ChatInitialLoadEvent>(_onChatInitialLoad);
    on<SendTextEvent>(_onSendText);
    on<SendImageEvent>(_onSendImage);
    on<SendStickerEvent>(_onSendSticker);
    on<EditMessageEvent>(_onEditMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<UpdateMessageReactionEvent>(_onUpdateMessageReaction);
    on<SendVoiceEvent>(_onSendVoice);
    on<FetchImageEvent>(_onFetchImageByMediaId);
    on<_LocalMessagesChangedEvent>((event, emit) {
      _currentMessages = event.messages;
      _requestMissingImageUrls(event.messages);
      emit(_buildChatLoaded(_currentMessages));
    });
    on<_LocalMessagesErrorEvent>((event, emit) => emit(ChatError(event.message)));
    on<_LocalConversationChangedEvent>((event, emit) {
      _currentConversation = event.conversation;
      emit(_buildChatLoaded(_currentMessages));
    });
  }

  ChatLoaded _buildChatLoaded(List<Message> messages) {
    return ChatLoaded(
      messages,
      uploadingImagePaths: Set<String>.from(_uploadingImagePaths),
      imageUrlsByMediaId: Map<String, String>.from(_imageUrlsByMediaId),
      resolvingImageMediaIds: Set<String>.from(_resolvingImageMediaIds),
      conversation: _currentConversation,
      currentUserId: _currentUserId,
    );
  }

  bool _isRemoteUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  bool _hasUsableResolvedImage(String mediaId) {
    final resolvedPath = _imageUrlsByMediaId[mediaId];
    if (resolvedPath == null || resolvedPath.trim().isEmpty) {
      return false;
    }

    if (_isRemoteUrl(resolvedPath)) {
      return true;
    }

    return File(resolvedPath).existsSync();
  }

  bool _isImageLikeMessage(Message message) {
    final mediaId = message.mediaId?.trim();
    if (mediaId == null || mediaId.isEmpty) {
      return false;
    }

    final normalizedType = message.type.trim().toLowerCase();
    return normalizedType == 'image' || normalizedType == 'file' || normalizedType == 'audio';
  }

  int _nextLocalOffset() {
    var maxOffset = -1;
    for (final message in _currentMessages) {
      final offset = message.offset;
      if (offset != null && offset > maxOffset) {
        maxOffset = offset;
      }
    }
    return maxOffset + 1;
  }

  void _requestMissingImageUrls(List<Message> messages) {
    for (final message in messages) {
      if (!_isImageLikeMessage(message) && message.type.trim().toLowerCase() != 'audio') {
        continue;
      }

      final mediaId = message.mediaId?.trim();
      if (mediaId == null || mediaId.isEmpty) {
        continue;
      }

      final hasUsableResolvedImage = _hasUsableResolvedImage(mediaId);
      if (!hasUsableResolvedImage) {
        _imageUrlsByMediaId.remove(mediaId);
      }

      if (hasUsableResolvedImage || _resolvingImageMediaIds.contains(mediaId)) {
        continue;
      }

      add(FetchImageEvent(mediaId));
    }
  }

  FutureOr<void> _onChatInitialLoad(ChatInitialLoadEvent event, Emitter<ChatState> emit) async {
    final userIdResult = await getCurrentUserIdUseCase();
    _currentUserId = userIdResult.fold((_) => _currentUserId, (id) => id);

    _startMessagesLocalWatcher(event.conversationId);
    _startConversationLocalWatcher(event.conversationId);
    emit(ChatLoading());
    final result = await fetchMessagesUseCase(event.conversationId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) {
        _currentMessages = messages;
        _requestMissingImageUrls(messages);
        emit(_buildChatLoaded(messages));
      },
    );
  }

  FutureOr<void> _onSendText(SendTextEvent event, Emitter<ChatState> emit) async {
    final messageId = Uuid().v4();
    final localOffset = _nextLocalOffset();
    final message = Message(
      id: messageId,
      conversationId: event.conversationId,
      senderId: _currentUserId ?? '',
      content: event.content,
      type: 'text',
      offset: localOffset,
      isDeleted: false,
      mediaId: event.mediaId,
      serverId: messageId,
      metadata: null,
      createdAt: DateTime.now().toUtc(),
      editedAt: null,
    );

    final sendResult = await sendMessageUseCase(message: message);
    sendResult.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );
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

  Future<void> _onSendImage(SendImageEvent event, Emitter<ChatState> emit) async {
    _uploadingImagePaths.add(event.imagePath);
    emit(_buildChatLoaded(_currentMessages));

    final result = await uploadMediaUseCase(
      event.imagePath,
      'image',
      event.imageSize,
    );
    final mediaId = result.fold(
          (failure) {
            add(_LocalMessagesErrorEvent(failure.message));
            return null;
          },
          (mediaInfo) {
            if (mediaInfo.mediaId == null || mediaInfo.mediaId!.isEmpty) {
              add(_LocalMessagesErrorEvent('Upload image failed: missing mediaId'));
              return null;
            }

            return mediaInfo.mediaId;
          },
    );

    if (mediaId == null) {
      _uploadingImagePaths.remove(event.imagePath);
      emit(_buildChatLoaded(_currentMessages));
      return;
    }

    final messageId = Uuid().v4();
    final localOffset = _nextLocalOffset();
    final message = Message(
      id: messageId,
      conversationId: event.conversationId,
      senderId: _currentUserId ?? '',
      content: event.imagePath,
      type: 'file',
      offset: localOffset,
      isDeleted: false,
      mediaId: mediaId,
      serverId: messageId,
      metadata: null,
      createdAt: DateTime.now().toUtc(),
      editedAt: null,
    );

    final sendResult = await sendMessageUseCase(message: message);
    sendResult.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );

    _uploadingImagePaths.remove(event.imagePath);
    emit(_buildChatLoaded(_currentMessages));
  }

  FutureOr<void> _onSendSticker(SendStickerEvent event, Emitter<ChatState> emit) async {
    final stickerUrl = event.stickerUrl.trim();
    if (stickerUrl.isEmpty) {
      add(const _LocalMessagesErrorEvent('Send sticker failed: missing sticker url'));
      return;
    }

    final messageId = Uuid().v4();
    final localOffset = _nextLocalOffset();
    final message = Message(
      id: messageId,
      conversationId: event.conversationId,
      senderId: _currentUserId ?? '',
      content: '',
      type: 'sticker',
      offset: localOffset,
      isDeleted: false,
      mediaId: null,
      serverId: messageId,
      metadata: <String, dynamic>{
        'url': stickerUrl,
        'stickerId': event.stickerId,
      },
      createdAt: DateTime.now().toUtc(),
      editedAt: null,
    );

    final sendResult = await sendMessageUseCase(message: message);
    sendResult.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );
  }

  FutureOr<void> _onEditMessage(EditMessageEvent event, Emitter<ChatState> emit) async {
    final result = await editMessageUseCase(
      localId: event.localId,
      messageId: event.messageId,
      content: event.content,
    );
    result.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );
  }

  FutureOr<void> _onDeleteMessage(DeleteMessageEvent event, Emitter<ChatState> emit) async {
    final result = await deleteMessageUseCase(
      localId: event.localId,
      messageId: event.messageId,
    );
    result.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );
  }

  FutureOr<void> _onUpdateMessageReaction(
    UpdateMessageReactionEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await updateMessageReactionUseCase(
      messageId: event.messageId,
      conversationId: event.conversationId,
      emoji: event.emoji,
      action: event.action,
    );
    result.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );
  }

  Future<void> _onSendVoice(SendVoiceEvent event, Emitter<ChatState> emit) async {
    final file = File(event.filePath);
    if (!file.existsSync()) {
      add(_LocalMessagesErrorEvent('Voice file not found'));
      return;
    }

    final fileSize = await file.length();
    final result = await uploadMediaUseCase(
      event.filePath,
      'audio',
      fileSize,
    );

    final mediaId = result.fold(
      (failure) {
        add(_LocalMessagesErrorEvent(failure.message));
        return null;
      },
      (mediaInfo) {
        if (mediaInfo.mediaId == null || mediaInfo.mediaId!.isEmpty) {
          add(_LocalMessagesErrorEvent('Upload audio failed: missing mediaId'));
          return null;
        }

        return mediaInfo.mediaId;
      },
    );

    if (mediaId == null) {
      return;
    }

    final messageId = Uuid().v4();
    final message = Message(
      id: messageId,
      conversationId: event.conversationId,
      senderId: _currentUserId ?? '',
      content: '',
      type: 'audio',
      offset: null,
      isDeleted: false,
      mediaId: mediaId,
      serverId: messageId,
      metadata: <String, dynamic>{
        'mediaId': mediaId,
        'durationMs': event.durationMs,
        'waveform': event.waveform.map((e) => e.toInt()).toList(),
      },
      createdAt: DateTime.now(),
      editedAt: null,
    );

    final sendResult = await sendMessageUseCase(message: message);
    sendResult.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );
  }

  Future<void> _onFetchImageByMediaId(
    FetchImageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final mediaId = event.mediaId.trim();
    if (mediaId.isEmpty) {
      return;
    }

    final hasUsableResolvedImage = _hasUsableResolvedImage(mediaId);
    if (!hasUsableResolvedImage) {
      _imageUrlsByMediaId.remove(mediaId);
    }

    if (hasUsableResolvedImage) {
      return;
    }

    final cachedFileInfo = await chatImageCacheManager.getFileFromCache(mediaId);
    if (cachedFileInfo?.file.path != null && cachedFileInfo!.file.path.trim().isNotEmpty) {
      _imageUrlsByMediaId[mediaId] = cachedFileInfo.file.path;
      emit(_buildChatLoaded(_currentMessages));
      return;
    }

    _resolvingImageMediaIds.add(mediaId);
    emit(_buildChatLoaded(_currentMessages));

    final result = await getImageUrlByMediaIdUseCase(mediaId);
    result.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (imageUrl) {
        if (imageUrl.trim().isNotEmpty) {
          _imageUrlsByMediaId[mediaId] = imageUrl;
        }
      },
    );

    _resolvingImageMediaIds.remove(mediaId);
    emit(_buildChatLoaded(_currentMessages));
  }

  void _startConversationLocalWatcher(String conversationId) {
    _conversationSubscription?.cancel();
    _conversationSubscription = watchConversationsLocalUseCase().listen((result) {
      if (isClosed) {
        return;
      }

      result.fold(
        (failure) => null,
        (conversations) {
          final matchingConversations = conversations.where((c) => c.id == conversationId);
          if (matchingConversations.isNotEmpty) {
            add(_LocalConversationChangedEvent(matchingConversations.first));
          }
        },
      );
    });
  }

  @override
  Future<void> close() async {
    _localSubscription?.cancel();
    _conversationSubscription?.cancel();
    await super.close();
  }
}


