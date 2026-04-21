import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/core/utils/waveform_utils.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/audio_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/image_media.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/features/upload_media/export.dart';
import 'package:flutter_chat/presentation/chat/chat_image_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
  final GetMediaPlayInfoUseCase getMediaPlayInfoUseCase;
  final GetMediaUrlByMediaIdUseCase getMediaUrlByMediaIdUseCase;
  final WatchConversationsLocalUseCase watchConversationsLocalUseCase;
  final AudioCacheDao audioCacheDao;

  String? _currentUserId;
  String? _currentConversationId;
  Conversation? _currentConversation;

  StreamSubscription<Either<Failure, List<Message>>>? _localSubscription;
  StreamSubscription<Either<Failure, List<Conversation>>>? _conversationSubscription;

  List<Message> _currentMessages = const [];
  final Set<String> _uploadingImagePaths = <String>{};
  final Map<String, String> _imageUrlsByMediaId = <String, String>{};
  final Map<String, String> _audioUrlsByMediaId = <String, String>{};
  final Set<String> _resolvingImageMediaIds = <String>{};
  final Set<String> _resolvingAudioMediaIds = <String>{};

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
    required this.getMediaPlayInfoUseCase,
    required this.getMediaUrlByMediaIdUseCase,
    required this.watchConversationsLocalUseCase,
    required this.audioCacheDao,
  }) : super(ChatInitial()) {
    on<ChatInitialLoadEvent>(_onChatInitialLoad);
    on<SendTextEvent>(_onSendText);
    on<SendImageEvent>(_onSendImage);
    on<SendStickerEvent>(_onSendSticker);
    on<SendAudioEvent>(_onSendAudio);
    on<EditMessageEvent>(_onEditMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<UpdateMessageReactionEvent>(_onUpdateMessageReaction);
    on<FetchImageEvent>(_onFetchImageByMediaId);
    on<FetchAudioEvent>(_onFetchAudioByMediaId);

    on<_LocalMessagesChangedEvent>((event, emit) {
      _currentMessages = event.messages;
      _requestMissingMediaUrls(event.messages);
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
      audioUrlsByMediaId: Map<String, String>.from(_audioUrlsByMediaId),
      resolvingImageMediaIds: Set<String>.from(_resolvingImageMediaIds),
      resolvingAudioMediaIds: Set<String>.from(_resolvingAudioMediaIds),
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

  Future<String?> _downloadAudioToLocal(String mediaId, String remoteUrl) async {
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
      if (!_isImageLikeMessage(message) && normalizedType != 'audio') {
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
          if (_currentConversationId == null || _currentConversationId!.trim().isEmpty) {
            debugPrint(
              '[VoiceHandle] getMediaPlayInfo skipped: missing conversationId mediaId=$mediaId',
            );
          }
          continue;
        }

        add(FetchAudioEvent(
          mediaId: mediaId,
          conversationId: _currentConversationId!,
        ));
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
    _currentConversationId = event.conversationId;

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
        _requestMissingMediaUrls(messages);
        emit(_buildChatLoaded(messages));
      },
    );
  }

  FutureOr<void> _onSendText(SendTextEvent event, Emitter<ChatState> emit) async {
    final messageId = Uuid().v4();
    final localOffset = _nextLocalOffset();
    final message = TextMessage(
      id: messageId,
      conversationId: event.conversationId,
      senderId: _currentUserId ?? '',
      text: event.content,
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

  void _startMessagesLocalWatcher(String conversationId) {
    _localSubscription?.cancel();
    _localSubscription = watchMessagesLocalUseCase(conversationId).listen((result) {
      result.fold(
        (failure) => add(_LocalMessagesErrorEvent(failure.message)),
        (messages) => add(_LocalMessagesChangedEvent(messages)),
      );
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

  FutureOr<void> _onSendSticker(SendStickerEvent event, Emitter<ChatState> emit) async {
    final stickerUrl = event.stickerUrl.trim();
    if (stickerUrl.isEmpty) {
      add(const _LocalMessagesErrorEvent('Send sticker failed: missing sticker url'));
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

  FutureOr<void> _onSendAudio(SendAudioEvent event, Emitter<ChatState> emit) async {
    final audioPath = event.audioPath.trim();
    if (audioPath.isEmpty) {
      add(const _LocalMessagesErrorEvent('Send audio failed: missing audio path'));
      return;
    }

    final file = File(audioPath);
    if (!file.existsSync()) {
      add(const _LocalMessagesErrorEvent('Voice file not found'));
      return;
    }

    final fileSize = await file.length();
    final uploadResult = await uploadMediaUseCase(audioPath, 'audio', fileSize);
    final mediaId = uploadResult.fold(
      (failure) {
        add(_LocalMessagesErrorEvent(failure.message));
        return null;
      },
      (mediaInfo) {
        if (mediaInfo.mediaId == null || mediaInfo.mediaId!.isEmpty) {
          add(const _LocalMessagesErrorEvent('Upload audio failed: missing mediaId'));
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

    final normalizedWaveform = WaveformUtils.normalize(event.waveform, maxBars: 64);
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

  FutureOr<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
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
      final downloadedPath = await _downloadAudioToLocal(mediaId, resolvedAudioUrl);
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
    final hasConversationId = normalizedConversationId != null &&
        normalizedConversationId.isNotEmpty;

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

      final urlFromMedia = mediaUrlResult.fold(
        (_) => '',
        (url) => url.trim(),
      );

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
