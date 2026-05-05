import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/core/utils/waveform_utils.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/audio_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/file_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/image_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/video_media.dart';
import 'package:flutter_chat/features/chat/domain/usecases/get_conversation_usecase.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/features/upload_media/domain/usecases/upload_multipart_usecase.dart';
import 'package:flutter_chat/features/upload_media/export.dart';
import 'package:flutter_chat/presentation/chat/chat_image_cache_manager.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessagesUseCase fetchMessagesUseCase;
  final FetchConversationDetailUseCase fetchConversationDetailUseCase;
  final GetConversationUseCase getConversationUseCase;
  final WatchMessagesLocalUseCase watchMessagesLocalUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final EditMessageUseCase editMessageUseCase;
  final ForwardMessageUseCase forwardMessageUseCase;
  final HiddenForMeUseCase hiddenForMeUseCase;
  final RevokeMessageUseCase revokeMessageUseCase;
  final UpdateMessageReactionUseCase updateMessageReactionUseCase;
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;
  final UploadMediaUseCase uploadMediaUseCase;
  final GetUrlByMediaIdUseCase getUrlByMediaIdUseCase;
  final GetMediaPlayInfoUseCase getMediaPlayInfoUseCase;
  final GetMediaUrlByMediaIdUseCase getMediaUrlByMediaIdUseCase;
  final WatchConversationsWithUsersUseCase watchConversationsWithUsersUseCase;
  final WatchPinMessageUseCase watchPinMessageUseCase;
  final FetchPinMessageUseCase fetchPinMessageUseCase;
  final PinMessageUseCase pinMessageUseCase;
  final UnpinMessageUseCase unpinMessageUseCase;
  final EmitTypingUseCase emitTypingUseCase;
  final UploadMultipartUseCase uploadMultipartUseCase;
  final AudioCacheDao audioCacheDao;

  String? _currentUserId;
  String? _currentConversationId;
  Conversation? _currentConversation;

  StreamSubscription<Either<Failure, List<Message>>>? _localSubscription;
  StreamSubscription<Either<Failure, List<Conversation>>>?
  _conversationSubscription;
  StreamSubscription<Either<Failure, List<PinMessage>>>? _pinSubscription;

  List<Message> _currentMessages = const [];
  List<PinMessage> _currentPinnedMessages = [];
  final Set<String> _uploadingImagePaths = <String>{};
  final Set<String> _uploadingFilePaths = <String>{};
  final Set<String> _uploadingVideoPaths = <String>{};
  final Map<String, String> _imageUrlsByMediaId = <String, String>{};
  final Map<String, String> _audioUrlsByMediaId = <String, String>{};
  final Map<String, String> _videoUrlsByMediaId = <String, String>{};
  final Map<String, String> _fileUrlsByMediaId = <String, String>{};
  final Set<String> _resolvingImageMediaIds = <String>{};
  final Set<String> _resolvingAudioMediaIds = <String>{};
  final Set<String> _resolvingVideoMediaIds = <String>{};

  ChatBloc({
    required this.fetchMessagesUseCase,
    required this.fetchConversationDetailUseCase,
    required this.getConversationUseCase,
    required this.watchMessagesLocalUseCase,
    required this.sendMessageUseCase,
    required this.editMessageUseCase,
    required this.forwardMessageUseCase,
    required this.hiddenForMeUseCase,
    required this.revokeMessageUseCase,
    required this.updateMessageReactionUseCase,
    required this.getCurrentUserIdUseCase,
    required this.uploadMediaUseCase,
    required this.getUrlByMediaIdUseCase,
    required this.getMediaPlayInfoUseCase,
    required this.getMediaUrlByMediaIdUseCase,
    required this.watchConversationsWithUsersUseCase,
    required this.watchPinMessageUseCase,
    required this.fetchPinMessageUseCase,
    required this.pinMessageUseCase,
    required this.unpinMessageUseCase,
    required this.uploadMultipartUseCase,
    required this.emitTypingUseCase,
    required this.audioCacheDao,
  }) : super(ChatInitial()) {
    on<ChatInitialLoadEvent>(_onChatInitialLoad);
    on<SendTextEvent>(_onSendText);
    on<SendImageEvent>(_onSendImage);
    on<SendMultipleImagesEvent>(_onSendMultipleImages);
    on<SendFileEvent>(_onSendFile);
    on<SendStickerEvent>(_onSendSticker);
    on<SendAudioEvent>(_onSendAudio);
    on<EditMessageEvent>(_onEditMessage);
    on<GetFileDownloadUrlEvent>(_onGetFileDownloadUrl);
    on<ForwardMessageEvent>(_forwardMessage);
    on<HiddenMessageEvent>(_hideMessage);
    on<RevokeMessageEvent>(_onRevokeMessage);
    on<UpdateMessageReactionEvent>(_onUpdateMessageReaction);
    on<FetchImageEvent>(_onFetchImageByMediaId);
    on<FetchAudioEvent>(_onFetchAudioByMediaId);
    on<FetchVideoEvent>(_onFetchVideoByMediaId);
    on<EmitTypingEvent>(_onEmitTyping);
    on<TypingChangedEvent>(_onTypingStatusChanged);
    on<LoadMoreMessagesEvent>(_loadMoreMessages);
    on<SendVideoEvent>(_onSendVideo);
    on<PinMessageEvent>(_onPinMessage);
    on<UnpinMessageEvent>(_onUnpinMessage);
    on<RefreshPinnedMessagesEvent>(_onRefreshPinnedMessages);
    on<_LocalPinnedMessagesChangedEvent>((event, emit) async {
      _currentPinnedMessages = event.pinnedMessages;

      final currentState = state;
      debugPrint(
        '[ChatBloc] Pinned messages updated: ${event.pinnedMessages.length} pinned messages',
      );
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(pinnedMessages: event.pinnedMessages));
      }
    });

    on<_LocalMessagesChangedEvent>((event, emit) async {
      _currentMessages = event.messages;
      _requestMissingMediaUrls(event.messages);
      emit(_buildChatLoaded(_currentMessages));
    });
    on<_LocalMessagesErrorEvent>(
      (event, emit) => emit(ChatError(event.message)),
    );
    on<_LocalConversationChangedEvent>((event, emit) {
      _currentConversation = event.conversation;
      emit(_buildChatLoaded(_currentMessages));
    });
  }

  ChatLoaded _buildChatLoaded(List<Message> messages) {
    return ChatLoaded(
      messages,
      uploadingImagePaths: Set<String>.from(_uploadingImagePaths),
      uploadingVideoPaths: Set<String>.from(_uploadingVideoPaths),
      imageUrlsByMediaId: Map<String, String>.from(_imageUrlsByMediaId),
      audioUrlsByMediaId: Map<String, String>.from(_audioUrlsByMediaId),
      videoUrlsByMediaId: Map<String, String>.from(_videoUrlsByMediaId),
      resolvingImageMediaIds: Set<String>.from(_resolvingImageMediaIds),
      resolvingAudioMediaIds: Set<String>.from(_resolvingAudioMediaIds),
      resolvingVideoMediaIds: Set<String>.from(_resolvingVideoMediaIds),
      conversation: _currentConversation,
      currentUserId: _currentUserId,
      pinnedMessages: _currentPinnedMessages,
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

  bool _hasUsableResolvedAudio(String mediaId) {
    final resolvedUrl = _audioUrlsByMediaId[mediaId];
    if (resolvedUrl == null || resolvedUrl.trim().isEmpty) {
      return false;
    }

    if (_isRemoteUrl(resolvedUrl)) {
      return true;
    }

    return File(resolvedUrl).existsSync();
  }

  String? _extractPlayableLocalAudioPath(Message message) {
    if (message is! AudioMessage) {
      return null;
    }

    final candidate = message.media.url?.trim();
    if (candidate == null || candidate.isEmpty) {
      return null;
    }

    if (_isRemoteUrl(candidate)) {
      return candidate;
    }

    return File(candidate).existsSync() ? candidate : null;
  }

  Future<String?> _resolveLocalAudioPath(String mediaId) async {
    final cachedPath = await audioCacheDao.getAudioPathByMediaId(mediaId);
    if (cachedPath == null || cachedPath.trim().isEmpty) {
      return null;
    }

    final file = File(cachedPath.trim());
    if (!file.existsSync()) {
      await audioCacheDao.deleteByMediaId(mediaId);
      return null;
    }

    return file.path;
  }

  Future<String?> _downloadAudioToLocal(
    String mediaId,
    String remoteUrl,
  ) async {
    final uri = Uri.tryParse(remoteUrl.trim());
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }

    final rootDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(rootDir.path, 'audio_cache'));
    if (!audioDir.existsSync()) {
      await audioDir.create(recursive: true);
    }

    final ext = p.extension(uri.path).trim();
    final fileExt = ext.isNotEmpty ? ext : '.m4a';
    final targetPath = p.join(audioDir.path, '$mediaId$fileExt');
    final targetFile = File(targetPath);

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }

      if (bytes.isEmpty) {
        return null;
      }

      await targetFile.writeAsBytes(bytes, flush: true);
      return targetFile.path;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  bool _isImageLikeMessage(Message message) {
    final mediaId = message.mediaId?.trim();
    if (mediaId == null || mediaId.isEmpty) {
      return false;
    }

    final normalizedType = message.type.trim().toLowerCase();
    return normalizedType == 'image' || normalizedType == 'file';
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

  void _requestMissingMediaUrls(List<Message> messages) {
    for (final message in messages) {
      final normalizedType = message.type.trim().toLowerCase();
      if (normalizedType == 'image' && message is ImageMessage) {
        for (final media in message.medias) {
          final mediaId = media.mediaId.trim();
          if (mediaId.isEmpty) {
            continue;
          }

          final hasUsableResolvedImage = _hasUsableResolvedImage(mediaId);
          if (!hasUsableResolvedImage) {
            _imageUrlsByMediaId.remove(mediaId);
          }

          if (hasUsableResolvedImage ||
              _resolvingImageMediaIds.contains(mediaId)) {
            continue;
          }

          add(FetchImageEvent(mediaId));
        }
        continue;
      }

      if (normalizedType == 'media' && message is MultiMediaMessage) {
        for (final media in message.medias) {
          if (media is! ImageMedia) {
            continue;
          }

          final mediaId = media.mediaId.trim();
          if (mediaId.isEmpty) {
            continue;
          }

          final hasUsableResolvedImage = _hasUsableResolvedImage(mediaId);
          if (!hasUsableResolvedImage) {
            _imageUrlsByMediaId.remove(mediaId);
          }

          if (hasUsableResolvedImage ||
              _resolvingImageMediaIds.contains(mediaId)) {
            continue;
          }

          add(FetchImageEvent(mediaId));
        }
        continue;
      }

      if (!_isImageLikeMessage(message) &&
          normalizedType != 'audio' &&
          normalizedType != 'video') {
        continue;
      }

      final mediaId = message.mediaId?.trim();
      if (mediaId == null || mediaId.isEmpty) {
        continue;
      }

      if (normalizedType == 'audio') {
        final localAudioPath = _extractPlayableLocalAudioPath(message);
        if (localAudioPath != null) {
          _audioUrlsByMediaId[mediaId] = localAudioPath;
          continue;
        }

        final hasUsableResolvedAudio = _hasUsableResolvedAudio(mediaId);
        if (!hasUsableResolvedAudio) {
          _audioUrlsByMediaId.remove(mediaId);
        }

        if (hasUsableResolvedAudio ||
            _resolvingAudioMediaIds.contains(mediaId) ||
            _currentConversationId == null ||
            _currentConversationId!.trim().isEmpty) {
          if (_currentConversationId == null ||
              _currentConversationId!.trim().isEmpty) {
            debugPrint(
              '[VoiceHandle] getMediaPlayInfo skipped: missing conversationId mediaId=$mediaId',
            );
          }
          continue;
        }

        add(
          FetchAudioEvent(
            mediaId: mediaId,
            conversationId: _currentConversationId!,
          ),
        );
        continue;
      }

      if (normalizedType == 'video') {
        if (_videoUrlsByMediaId[mediaId]?.trim().isNotEmpty == true ||
            _resolvingVideoMediaIds.contains(mediaId) ||
            _currentConversationId == null ||
            _currentConversationId!.trim().isEmpty) {
          continue;
        }

        add(
          FetchVideoEvent(
            mediaId: mediaId,
            conversationId: _currentConversationId!,
          ),
        );

        if (message is VideoMessage) {
          final thumbMediaId = message.media.thumbMediaId?.trim();
          if (thumbMediaId != null &&
              thumbMediaId.isNotEmpty &&
              !_hasUsableResolvedImage(thumbMediaId) &&
              !_resolvingImageMediaIds.contains(thumbMediaId)) {
            add(FetchImageEvent(thumbMediaId));
          }
        }
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

  FutureOr<void> _onChatInitialLoad(
    ChatInitialLoadEvent event,
    Emitter<ChatState> emit,
  ) async {
    _currentConversationId = event.conversationId;

    final userIdResult = await getCurrentUserIdUseCase();
    _currentUserId = userIdResult.fold((_) => _currentUserId, (id) => id);

    _startMessagesLocalWatcher(event.conversationId);
    _startConversationLocalWatcher(event.conversationId);
    _startPinMessageWatcher(event.conversationId);

    if (_currentMessages.isEmpty) {
      emit(ChatLoading());
    }

    unawaited(fetchMessagesUseCase(event.conversationId));
    unawaited(fetchConversationDetailUseCase(event.conversationId));
    unawaited(fetchPinMessageUseCase(event.conversationId));
  }

  FutureOr<void> _onPinMessage(
    PinMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await pinMessageUseCase(
      messageId: event.messageId,
      conversationId: event.conversationId,
    );

    result.fold(
      (failure) => debugPrint('[ChatBloc] pinMessage failed: ${failure.message}'),
      (_) => null,
    );
  }

  FutureOr<void> _onUnpinMessage(
    UnpinMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await unpinMessageUseCase(
      messageId: event.messageId,
      conversationId: event.conversationId,
    );

    result.fold(
      (failure) => debugPrint('[ChatBloc] unpinMessage failed: ${failure.message}'),
      (_) => null,
    );
  }

  FutureOr<void> _onRefreshPinnedMessages(
    RefreshPinnedMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await fetchPinMessageUseCase(event.conversationId);
    result.fold(
      (failure) => debugPrint(
        '[ChatBloc] refresh pinned failed: ${failure.message}',
      ),
      (_) => null,
    );
  }

  FutureOr<void> _onSendText(
    SendTextEvent event,
    Emitter<ChatState> emit,
  ) async {
    final messageId = Uuid().v4();
    final localOffset = _nextLocalOffset();
    final normalizedReplyToId = event.replyToMessageId?.trim();
    final hasReply =
        normalizedReplyToId != null && normalizedReplyToId.isNotEmpty;
    final message = TextMessage(
      id: messageId,
      conversationId: event.conversationId,
      senderId: _currentUserId ?? '',
      text: event.content,
      replyToId: hasReply ? normalizedReplyToId : null,
      offset: localOffset,
      isDeleted: false,
      serverId: messageId,
      createdAt: DateTime.now().toUtc(),
      editedAt: null,
    );

    final sendResult = await sendMessageUseCase(
      message: message,
      replyToMessageId: hasReply ? normalizedReplyToId : null,
      mentions: event.mentions,
    );
    sendResult.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );
  }

  void _startMessagesLocalWatcher(String conversationId) {
    _localSubscription?.cancel();
    _localSubscription = watchMessagesLocalUseCase(conversationId).listen((
      result,
    ) {
      result.fold((failure) => add(_LocalMessagesErrorEvent(failure.message)), (
        messages,
      ) {
        add(_LocalMessagesChangedEvent(messages));
        for (final msg in messages.whereType<FileMessage>()) {
          debugPrint(
            '[ChatBloc] FILE message: '
            'id=${msg.id}, '
            'fileName=${msg.fileName}, '
            'size=${msg.fileSize}',
          );
        }
      });
    });
  }

  void _startConversationLocalWatcher(String conversationId) {
    _conversationSubscription?.cancel();
    _conversationSubscription = watchConversationsWithUsersUseCase().listen((
      result,
    ) {
      if (isClosed) {
        return;
      }

      result.fold((failure) => null, (conversations) {
        final matchingConversations = conversations.where(
          (c) => c.id == conversationId,
        );
        if (matchingConversations.isNotEmpty) {
          add(_LocalConversationChangedEvent(matchingConversations.first));
        }
      });
    });
  }

  void _startPinMessageWatcher(String conversationId) {
    _pinSubscription?.cancel();
    _pinSubscription = watchPinMessageUseCase(conversationId).listen((result) {
      if (isClosed) {
        return;
      }

      result.fold((failure) => null, (pinMessages) {
        if (conversationId != _currentConversationId) return;
        add(_LocalPinnedMessagesChangedEvent(pinMessages));
      });
    });
  }

  Future<void> _onSendImage(
    SendImageEvent event,
    Emitter<ChatState> emit,
  ) async {
    _uploadingImagePaths.add(event.imagePath);
    emit(_buildChatLoaded(_currentMessages));

    final result = await uploadMediaUseCase(
      event.imagePath,
      'image',
      event.imageSize,
      null,
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
    final message = ImageMessage(
      id: messageId,
      conversationId: event.conversationId,
      senderId: _currentUserId ?? '',
      medias: <ImageMedia>[ImageMedia(id: mediaId)],
      offset: localOffset,
      isDeleted: false,
      serverId: messageId,
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

  Future<void> _onSendMultipleImages(
    SendMultipleImagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.imagePaths.isEmpty) {
      return;
    }

    if (event.imagePaths.length != event.imageSizes.length) {
      add(
        const _LocalMessagesErrorEvent(
          'Send images failed: invalid upload payload',
        ),
      );
      return;
    }

    _uploadingImagePaths.addAll(event.imagePaths);
    emit(_buildChatLoaded(_currentMessages));

    final uploadedMediaIds = <String>[];
    var failedCount = 0;

    for (var index = 0; index < event.imagePaths.length; index++) {
      final imagePath = event.imagePaths[index];
      final imageSize = event.imageSizes[index];
      final uploadResult = await uploadMediaUseCase(
        imagePath,
        'image',
        imageSize,
        null,
      );

      uploadResult.fold(
        (failure) {
          failedCount++;
          add(_LocalMessagesErrorEvent(failure.message));
        },
        (mediaInfo) {
          final mediaId = mediaInfo.mediaId?.trim() ?? '';
          if (mediaId.isEmpty) {
            failedCount++;
            add(
              const _LocalMessagesErrorEvent(
                'Upload image failed: missing mediaId',
              ),
            );
            return;
          }
          uploadedMediaIds.add(mediaId);
        },
      );
    }

    if (uploadedMediaIds.isNotEmpty) {
      final messageId = Uuid().v4();
      final localOffset = _nextLocalOffset();
      final message = MultiMediaMessage(
        id: messageId,
        conversationId: event.conversationId,
        senderId: _currentUserId ?? '',
        medias: uploadedMediaIds
            .map((mediaId) => ImageMedia(id: mediaId))
            .toList(growable: false),
        caption: '',
        offset: localOffset,
        isDeleted: false,
        serverId: messageId,
        createdAt: DateTime.now().toUtc(),
        editedAt: null,
      );

      final sendResult = await sendMessageUseCase(message: message);
      sendResult.fold(
        (failure) => add(_LocalMessagesErrorEvent(failure.message)),
        (_) {},
      );
    }

    _uploadingImagePaths.removeAll(event.imagePaths);

    if (uploadedMediaIds.isEmpty && failedCount > 0) {
      add(const _LocalMessagesErrorEvent('Failed to upload selected images'));
    }

    emit(_buildChatLoaded(_currentMessages));
  }

  FutureOr<void> _onSendFile(
    SendFileEvent event,
    Emitter<ChatState> emit,
  ) async {
    _uploadingFilePaths.add(event.filePath);
    emit(_buildChatLoaded(_currentMessages));

    final result = await uploadMediaUseCase(
      event.filePath,
      'file',
      event.fileSize,
      event.fileName,
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
      _uploadingFilePaths.remove(event.filePath);
      emit(_buildChatLoaded(_currentMessages));
      return;
    }

    final messageId = Uuid().v4();
    final localOffset = _nextLocalOffset();
    final message = FileMessage(
      id: messageId,
      conversationId: event.conversationId,
      senderId: _currentUserId ?? '',
      medias: <FileMedia>[
        FileMedia(id: mediaId, size: event.fileSize, mediaType: 'file'),
      ],
      caption: event.fileName,
      offset: localOffset,
      isDeleted: false,
      serverId: messageId,
      createdAt: DateTime.now().toUtc(),
      editedAt: null,
    );

    final sendResult = await sendMessageUseCase(message: message);
    sendResult.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );

    _uploadingFilePaths.remove(event.filePath);
    emit(_buildChatLoaded(_currentMessages));
  }

  FutureOr<void> _onSendSticker(
    SendStickerEvent event,
    Emitter<ChatState> emit,
  ) async {
    final stickerUrl = event.stickerUrl.trim();
    if (stickerUrl.isEmpty) {
      add(
        const _LocalMessagesErrorEvent(
          'Send sticker failed: missing sticker url',
        ),
      );
      return;
    }

    final messageId = Uuid().v4();
    final localOffset = _nextLocalOffset();
    final message = StickerMessage(
      id: messageId,
      conversationId: event.conversationId,
      senderId: _currentUserId ?? '',
      stickerUrl: stickerUrl,
      stickerId: event.stickerId,
      stickerText: '',
      offset: localOffset,
      isDeleted: false,
      serverId: messageId,
      createdAt: DateTime.now().toUtc(),
      editedAt: null,
    );

    final sendResult = await sendMessageUseCase(message: message);
    sendResult.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );
  }

  FutureOr<void> _onSendAudio(
    SendAudioEvent event,
    Emitter<ChatState> emit,
  ) async {
    final audioPath = event.audioPath.trim();
    if (audioPath.isEmpty) {
      add(
        const _LocalMessagesErrorEvent('Send audio failed: missing audio path'),
      );
      return;
    }

    final file = File(audioPath);
    if (!file.existsSync()) {
      add(const _LocalMessagesErrorEvent('Voice file not found'));
      return;
    }

    final fileSize = await file.length();
    final uploadResult = await uploadMediaUseCase(
      audioPath,
      'audio',
      fileSize,
      null,
    );
    final mediaId = uploadResult.fold(
      (failure) {
        add(_LocalMessagesErrorEvent(failure.message));
        return null;
      },
      (mediaInfo) {
        if (mediaInfo.mediaId == null || mediaInfo.mediaId!.isEmpty) {
          add(
            const _LocalMessagesErrorEvent(
              'Upload audio failed: missing mediaId',
            ),
          );
          return null;
        }
        return mediaInfo.mediaId;
      },
    );

    if (mediaId == null) {
      return;
    }

    await audioCacheDao.saveAudioPath(mediaId: mediaId, localPath: audioPath);
    _audioUrlsByMediaId[mediaId] = audioPath;
    emit(_buildChatLoaded(_currentMessages));

    final normalizedWaveform = WaveformUtils.normalize(
      event.waveform,
      maxBars: 64,
    );
    final localOffset = _nextLocalOffset();
    final messageId = Uuid().v4();
    final message = AudioMessage(
      id: messageId,
      conversationId: event.conversationId,
      senderId: _currentUserId ?? '',
      media: AudioMedia(
        id: mediaId,
        url: audioPath,
        durationMs: event.durationMs,
        waveform: normalizedWaveform,
      ),
      offset: localOffset,
      isDeleted: false,
      serverId: messageId,
      createdAt: DateTime.now().toUtc(),
      editedAt: null,
    );

    final sendResult = await sendMessageUseCase(message: message);
    sendResult.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );
  }

  FutureOr<void> _onEditMessage(
    EditMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
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

  Future<void> _onGetFileDownloadUrl(
    GetFileDownloadUrlEvent event,
    Emitter<ChatState> emit,
  ) async {
    final dir = await getTemporaryDirectory();
    debugPrint('[ChatBloc] Get file download URL for mediaId=${event.mediaId}');
    debugPrint(
      '[ChatBloc] Get file download URL for filename=${event.fileName}',
    );
    final mediaId = event.mediaId.trim();
    if (mediaId.isEmpty) {
      add(
        const _LocalMessagesErrorEvent(
          'Get file download URL failed: missing mediaId',
        ),
      );
      return;
    }

    final result = await getMediaUrlByMediaIdUseCase(event.mediaId);
    result.fold(
      (failure) {
        add(_LocalMessagesErrorEvent(failure.message));
      },
      (mediaUrl) async {
        try {
          final filePath = "${dir.path}/${event.fileName}";
          final file = File(filePath);

          ///nếu đã có file → open luôn (cache)
          if (await file.exists()) {
            await _openFile(filePath);
            return;
          }

          ///download
          final dio = Dio();

          await dio.download(
            mediaUrl,
            filePath,
            onReceiveProgress: (received, total) {
              /// nếu muốn update progress thì emit state ở đây
            },
          );

          _fileUrlsByMediaId[mediaId] = filePath;

          ///open file
          await _openFile(filePath);
        } catch (e) {
          add(_LocalMessagesErrorEvent("Download failed"));
        }
      },
    );
  }

  Future<void> _openFile(String path) async {
    final result = await OpenFilex.open(path);

    if (result.type != ResultType.done) {
      throw Exception("Cannot open file");
    }
  }

  Future<void> _forwardMessage(
    ForwardMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await forwardMessageUseCase(
      sourceMessageId: event.messageId,
      sourceConversationId: event.srcConversationId,
      targetConversationIds: event.targetConversationIds,
    );

    result.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );
  }

  Future<void> _hideMessage(
    HiddenMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await hiddenForMeUseCase(
      event.localId,
      event.messageId,
      event.conversationId,
    );

    result.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );
  }

  FutureOr<void> _onRevokeMessage(
    RevokeMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await revokeMessageUseCase(
      localId: event.localId,
      messageId: event.messageId,
      conversationId: event.conversationId,
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

    final cachedFileInfo = await chatImageCacheManager.getFileFromCache(
      mediaId,
    );
    if (cachedFileInfo?.file.path != null &&
        cachedFileInfo!.file.path.trim().isNotEmpty) {
      _imageUrlsByMediaId[mediaId] = cachedFileInfo.file.path;
      emit(_buildChatLoaded(_currentMessages));
      return;
    }

    _resolvingImageMediaIds.add(mediaId);
    emit(_buildChatLoaded(_currentMessages));

    final result = await getUrlByMediaIdUseCase(mediaId);
    result.fold((failure) => add(_LocalMessagesErrorEvent(failure.message)), (
      imageUrl,
    ) {
      if (imageUrl.trim().isNotEmpty) {
        _imageUrlsByMediaId[mediaId] = imageUrl;
      }
    });

    _resolvingImageMediaIds.remove(mediaId);
    emit(_buildChatLoaded(_currentMessages));
  }

  Future<void> _onFetchAudioByMediaId(
    FetchAudioEvent event,
    Emitter<ChatState> emit,
  ) async {
    final mediaId = event.mediaId.trim();
    if (mediaId.isEmpty) {
      return;
    }

    final localAudioPath = await _resolveLocalAudioPath(mediaId);
    if (localAudioPath != null) {
      _audioUrlsByMediaId[mediaId] = localAudioPath;
      emit(_buildChatLoaded(_currentMessages));
      return;
    }

    final hasUsableResolvedAudio = _hasUsableResolvedAudio(mediaId);
    if (!hasUsableResolvedAudio) {
      _audioUrlsByMediaId.remove(mediaId);
    }

    if (hasUsableResolvedAudio) {
      return;
    }

    if (_resolvingAudioMediaIds.contains(mediaId)) {
      return;
    }

    _resolvingAudioMediaIds.add(mediaId);

    final resolvedAudioUrl = await _resolveAudioUrlFromServer(
      mediaId: mediaId,
      conversationId: event.conversationId,
    );

    if (resolvedAudioUrl.isNotEmpty) {
      final downloadedPath = await _downloadAudioToLocal(
        mediaId,
        resolvedAudioUrl,
      );
      if (downloadedPath != null && downloadedPath.trim().isNotEmpty) {
        _audioUrlsByMediaId[mediaId] = downloadedPath;
        await audioCacheDao.saveAudioPath(
          mediaId: mediaId,
          localPath: downloadedPath,
        );
      } else {
        _audioUrlsByMediaId[mediaId] = resolvedAudioUrl;
      }
    } else {
      add(_LocalMessagesErrorEvent('Cannot resolve playable audio URL'));
    }

    _resolvingAudioMediaIds.remove(mediaId);

    emit(_buildChatLoaded(_currentMessages));
  }

  Future<String> _resolveAudioUrlFromServer({
    required String mediaId,
    String? conversationId,
  }) async {
    final normalizedConversationId = conversationId?.trim();
    final hasConversationId =
        normalizedConversationId != null && normalizedConversationId.isNotEmpty;

    final candidates = <String?>[
      if (hasConversationId) normalizedConversationId,
      null,
    ];

    for (final candidateConversationId in candidates) {
      final playInfoResult = await getMediaPlayInfoUseCase(
        mediaId,
        conversationId: candidateConversationId,
      );

      final urlFromPlayInfo = playInfoResult.fold(
        (_) => '',
        (payload) => _extractMediaUrl(payload),
      );

      if (urlFromPlayInfo.trim().isNotEmpty) {
        return urlFromPlayInfo.trim();
      }

      final mediaUrlResult = await getMediaUrlByMediaIdUseCase(
        mediaId,
        conversationId: candidateConversationId,
      );

      final urlFromMedia = mediaUrlResult.fold((_) => '', (url) => url.trim());

      if (urlFromMedia.isNotEmpty) {
        return urlFromMedia;
      }
    }

    return '';
  }

  Future<void> _onFetchVideoByMediaId(
    FetchVideoEvent event,
    Emitter<ChatState> emit,
  ) async {
    final mediaId = event.mediaId.trim();
    if (mediaId.isEmpty) {
      return;
    }

    if (_videoUrlsByMediaId[mediaId]?.trim().isNotEmpty == true ||
        _resolvingVideoMediaIds.contains(mediaId)) {
      return;
    }

    _resolvingVideoMediaIds.add(mediaId);
    final resolvedVideoUrl = await _resolveMediaUrlFromServer(
      mediaId: mediaId,
      conversationId: event.conversationId,
    );

    if (resolvedVideoUrl.isNotEmpty) {
      _videoUrlsByMediaId[mediaId] = resolvedVideoUrl;
    } else {
      add(_LocalMessagesErrorEvent('Cannot resolve playable video URL'));
    }

    _resolvingVideoMediaIds.remove(mediaId);
    emit(_buildChatLoaded(_currentMessages));
  }

  Future<String> _resolveMediaUrlFromServer({
    required String mediaId,
    String? conversationId,
  }) async {
    final normalizedConversationId = conversationId?.trim();
    final hasConversationId =
        normalizedConversationId != null && normalizedConversationId.isNotEmpty;

    final candidates = <String?>[
      if (hasConversationId) normalizedConversationId,
      null,
    ];

    for (final candidateConversationId in candidates) {
      final playInfoResult = await getMediaPlayInfoUseCase(
        mediaId,
        conversationId: candidateConversationId,
      );

      final urlFromPlayInfo = playInfoResult.fold(
        (_) => '',
        (payload) => _extractMediaUrl(payload),
      );

      if (urlFromPlayInfo.trim().isNotEmpty) {
        return urlFromPlayInfo.trim();
      }

      final mediaUrlResult = await getMediaUrlByMediaIdUseCase(
        mediaId,
        conversationId: candidateConversationId,
      );

      final urlFromMedia = mediaUrlResult.fold((_) => '', (url) => url.trim());

      if (urlFromMedia.isNotEmpty) {
        return urlFromMedia;
      }
    }

    return '';
  }

  String _extractMediaUrl(Map<String, dynamic> payload) {
    final directUrl = _extractUrlFromMap(payload);
    if (directUrl.isNotEmpty) {
      return directUrl;
    }

    final nestedData = payload['data'];
    if (nestedData is Map) {
      return _extractUrlFromMap(Map<String, dynamic>.from(nestedData));
    }

    for (final value in payload.values) {
      if (value is Map<String, dynamic>) {
        final nestedUrl = _extractMediaUrl(value);
        if (nestedUrl.isNotEmpty) {
          return nestedUrl;
        }
      } else if (value is Map) {
        final nestedUrl = _extractMediaUrl(Map<String, dynamic>.from(value));
        if (nestedUrl.isNotEmpty) {
          return nestedUrl;
        }
      }
    }

    return '';
  }

  String _extractUrlFromMap(Map<String, dynamic> source) {
    const candidateKeys = <String>[
      'url',
      'audioUrl',
      'audio_url',
      'videoUrl',
      'video_url',
      'playUrl',
      'play_url',
      'hls',
      'hlsUrl',
      'hls_url',
      'optimizedUrl',
      'optimized_url',
      'mediaUrl',
      'media_url',
    ];

    for (final key in candidateKeys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    for (final value in source.values) {
      if (value is Map<String, dynamic>) {
        final nestedUrl = _extractUrlFromMap(value);
        if (nestedUrl.isNotEmpty) {
          return nestedUrl;
        }
      } else if (value is Map) {
        final nestedUrl = _extractUrlFromMap(Map<String, dynamic>.from(value));
        if (nestedUrl.isNotEmpty) {
          return nestedUrl;
        }
      }
    }

    return '';
  }

  @override
  Future<void> close() async {
    _localSubscription?.cancel();
    _conversationSubscription?.cancel();
    await super.close();
  }

  FutureOr<void> _onEmitTyping(EmitTypingEvent event, Emitter<ChatState> emit) {
    emitTypingUseCase(event.conversationId, event.isTyping);
  }

  FutureOr<void> _onTypingStatusChanged(
    TypingChangedEvent event,
    Emitter<ChatState> emit,
  ) {
    final state = this.state;

    if (state is! ChatLoaded) return null;

    if (event.conversationId != state.conversation?.id) return null;

    if (event.userId == state.currentUserId) return null;

    final typingUsers = Set<String>.from(state.typingUserIds);
    final typingNames = Map<String, String>.from(state.typingUsernames);

    if (event.isTyping) {
      typingUsers.add(event.userId);

      if (event.username != null) {
        typingNames[event.userId] = event.username!;
      }
    } else {
      typingUsers.remove(event.userId);
      typingNames.remove(event.userId);
    }

    emit(
      state.copyWith(typingUserIds: typingUsers, typingUsernames: typingNames),
    );
  }

  FutureOr<void> _loadMoreMessages(
    LoadMoreMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatLoaded) return null;
    if (_currentConversationId == null ||
        _currentConversationId!.trim().isEmpty)
      return null;

    final validMessages = current.messages
        .where((m) => m.offset != null)
        .toList();
    if (validMessages.isEmpty) return null;

    final oldestOffset = validMessages
        .map((m) => m.offset!)
        .reduce((a, b) => a < b ? a : b);
    emit(current.copyWith(isLoadingMore: true));

    final result = await fetchMessagesUseCase(
      _currentConversationId!,
      before: oldestOffset,
      limit: 30,
    );
    result.fold(
      (failure) {
        emit(current.copyWith(isLoadingMore: false));
      },
      (newMessages) {
        // merge + dedupe
        final merged = [...newMessages, ...current.messages];

        final map = <String, Message>{};
        for (final m in merged) {
          final key = m.serverId ?? m.id;
          map[key] = m;
        }

        final sorted = map.values.toList()
          ..sort((a, b) => (a.offset ?? 0).compareTo(b.offset ?? 0));

        emit(
          current.copyWith(
            messages: sorted,
            isLoadingMore: false,
            hasMoreOld: newMessages.length == 30,
          ),
        );
      },
    );
  }

  Future<void> _onSendVideo(
    SendVideoEvent event,
    Emitter<ChatState> emit,
  ) async {
    _uploadingVideoPaths.add(event.file.path);
    emit(_buildChatLoaded(_currentMessages));

    final thumbnail = await _generateVideoThumbnail(event.file);
    String? thumbId;
    if (thumbnail != null) {
      final thumbResult = await uploadMediaUseCase(
        thumbnail.path,
        'image',
        thumbnail.lengthSync(),
        null,
      );

      thumbId = thumbResult.fold(
        (failure) {
          debugPrint(
            '[ChatBloc] Failed to upload video thumbnail: ${failure.message}',
          );
          return null;
        },
        (mediaInfo) {
          if (mediaInfo.mediaId == null || mediaInfo.mediaId!.isEmpty) {
            debugPrint(
              '[ChatBloc] Failed to upload video thumbnail: missing mediaId',
            );
            return null;
          }
          return mediaInfo.mediaId;
        },
      );
    }

    final result = await uploadMultipartUseCase(event.file, (progress) {
      debugPrint(
        '[ChatBloc] Video upload progress: $progress% for path=${event.file.path}',
      );
      //TODO: emit progress state if needed
    });

    final mediaId = result.fold(
      (failure) {
        add(_LocalMessagesErrorEvent(failure.message));
        return null;
      },
      (mediaId) {
        if (mediaId.isEmpty) {
          add(_LocalMessagesErrorEvent('Upload video failed: missing mediaId'));
          return null;
        }
        return mediaId;
      },
    );

    if (mediaId == null) {
      _uploadingVideoPaths.remove(event.file.path);
      emit(_buildChatLoaded(_currentMessages));
      return;
    }

    final messageId = Uuid().v4();
    final localOffset = _nextLocalOffset();
    final videoMedia = VideoMedia(
      id: mediaId,
      fileName: event.file.path.split(Platform.pathSeparator).last,
      size: event.file.lengthSync(),
      mimeType: lookupMimeType(event.file.path) ?? 'video/mp4',
      durationMs: await _getVideoDuration(event.file),
      bitrate: await _getBitrate(event.file.path),
      thumbMediaId: thumbId,
    );
    final message = VideoMessage(
      id: messageId,
      conversationId: event.conversationId,
      senderId: _currentUserId ?? '',
      offset: localOffset,
      isDeleted: false,
      serverId: messageId,
      createdAt: DateTime.now().toUtc(),
      editedAt: null,
      media: videoMedia,
    );

    final sendResult = await sendMessageUseCase(message: message);
    sendResult.fold(
      (failure) => add(_LocalMessagesErrorEvent(failure.message)),
      (_) {},
    );

    _uploadingVideoPaths.remove(event.file.path);
    emit(_buildChatLoaded(_currentMessages));
  }

  Future<int> _getBitrate(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();

    if (info == null) return 0;

    final props = info.getAllProperties();

    final bitrateStr = props?['bit_rate'];

    return int.tryParse(bitrateStr ?? '') ?? 0;
  }

  Future<int> _getVideoDuration(File file) async {
    final controller = VideoPlayerController.file(file);

    await controller.initialize(); // load metadata

    await controller.dispose();

    return controller.value.duration.inMilliseconds;
  }

  Future<File?> _generateVideoThumbnail(File videoFile) async {
    try {
      final outputPath = p.join(
        videoFile.parent.path,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final command =
          '-i "${videoFile.path}" -ss 00:00:01 -vframes 1 "$outputPath"';

      await FFmpegKit.execute(command);

      final file = File(outputPath);

      if (await file.exists()) {
        return file;
      }

      return null;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }
}
