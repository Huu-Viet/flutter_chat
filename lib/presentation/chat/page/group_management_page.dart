import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/core/utils/file_utils.dart';
import 'package:flutter_chat/features/auth/domain/entities/user.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation_participant.dart';
import 'package:flutter_chat/features/group_manager/data/datasources/api/group_management_service.dart';
import 'package:flutter_chat/presentation/chat/blocs/chat_ui_actions_cubit.dart';
import 'package:flutter_chat/presentation/chat/widgets/share_invite_link_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_chat/features/group_manager/group_management_provider.dart';
import 'package:flutter_chat/features/upload_media/upload_media_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class GroupManagementPage extends ConsumerStatefulWidget {
  final Conversation conversation;
  final String currentUserId;

  const GroupManagementPage({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  @override
  ConsumerState<GroupManagementPage> createState() =>
      _GroupManagementPageState();
}

class _GroupManagementPageState extends ConsumerState<GroupManagementPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late List<ConversationParticipant> _participants;
  late bool _allowMemberMessage;
  late bool _isPublic;
  late bool _joinApprovalRequired;

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _memberSearchController;
  final MediaService _mediaService = MediaService();
  late final ChatUiActionsCubit _chatUiActionsCubit;
  String? _pickedAvatarPath;
  String? _uploadedAvatarMediaId;

  bool _busyInfo = false;
  bool _busySettings = false;
  bool _busyInvite = false;
  bool _busyRequests = false;
  bool _busyPolls = false;
  bool _openingPollDialog = false;
  bool _submittingPoll = false;
  bool _busyAppointments = false;
  bool _appointmentsEndpointUnsupported = false;
  bool _busyNotify = false;
  bool _busyDanger = false;
  bool _busyMemberSearch = false;
  bool _busyAddMember = false;
  bool _hasSearchedMember = false;

  String? _inviteUrl;
  String? _inviteExpiresAt;
  String _muteDuration = '1';

  List<Map<String, dynamic>> _joinRequests = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _polls = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _appointments = <Map<String, dynamic>>[];
  List<MyUser> _memberSearchResults = const <MyUser>[];

  @override
  void initState() {
    super.initState();
    _chatUiActionsCubit = ChatUiActionsCubit(
      uploadMediaAction: (path, mediaType, size, fileName) =>
          ref.read(uploadMediaUseCaseProvider)(
            path,
            mediaType,
            size,
            fileName,
          ),
      searchUsersByUsernameAction: (query, {page = 1, limit = 20}) =>
          ref.read(searchUsersByUsernameUseCaseProvider)(
            query,
            page: page,
            limit: limit,
          ),
    );
    _participants = List<ConversationParticipant>.from(
      widget.conversation.participants,
    );
    _allowMemberMessage = widget.conversation.allowMemberMessage;
    _isPublic = widget.conversation.isPublic;
    _joinApprovalRequired = widget.conversation.joinApprovalRequired;
    _nameController = TextEditingController(text: widget.conversation.name);
    _descriptionController = TextEditingController(
      text: widget.conversation.description,
    );
    _memberSearchController = TextEditingController();
    _tabController = TabController(length: _visibleTabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncParticipantsFromServer();
      _loadInviteLink();
      _loadJoinRequests();
      _loadPolls();
      _loadAppointments();
    });
  }

  @override
  void dispose() {
    _chatUiActionsCubit.close();
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _memberSearchController.dispose();
    super.dispose();
  }

  Dio get _dio => ref.read(authDioProvider);
  GroupManagementService get _groupManagementService =>
      ref.read(groupManagementServiceProvider);
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  String _url(String path) {
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$base$normalizedPath';
  }

  Options get _requestOptions => Options(
    connectTimeout: const Duration(seconds: 25),
    sendTimeout: const Duration(seconds: 25),
    receiveTimeout: const Duration(seconds: 25),
  );

  String get _myRole {
    final normalizedCurrentUserId = widget.currentUserId.trim();
    if (normalizedCurrentUserId.isEmpty) {
      return 'member';
    }

    final participant = _participants.where((item) {
      return item.userId.trim() == normalizedCurrentUserId;
    }).toList();

    if (participant.isEmpty) {
      return 'member';
    }

    return participant.first.role.trim().toLowerCase();
  }

  bool get _isAdminOrOwner => _myRole == 'owner' || _myRole == 'admin';

  Set<String> get _participantIds {
    return _participants
        .map((item) => item.userId.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  List<String> get _visibleTabs {
    if (_isAdminOrOwner) {
      return const <String>['Info', 'Member', 'Settings', 'Invite', 'Request'];
    }
    return const <String>['Info', 'Member', 'Settings'];
  }

  dynamic _unwrap(dynamic payload) {
    if (payload is Map<String, dynamic> && payload.containsKey('data')) {
      return payload['data'];
    }
    return payload;
  }

  String _errorMessageFor(Object error, {required String fallback}) {
    final parsed = _parseBackendError(error);
    if (parsed == null) {
      return fallback;
    }

    final errorCode = (parsed['errorCode'] as String?)?.toUpperCase();
    final statusCode = parsed['statusCode'] as int?;
    final backendMessage = (parsed['message'] as String?)?.trim();

    const codeMessageMap = <String, String>{
      'RESOURCE_CONFLICT':
          'Action cannot be completed because the current state has changed.',
      'FORBIDDEN_NOT_MEMBER': 'You are no longer a member of this group.',
      'FORBIDDEN_ROLE_REQUIRED': 'You do not have permission for this action.',
      'FORBIDDEN_NOT_OWNER': 'Only the owner can perform this action.',
      'FORBIDDEN_TIME_WINDOW':
          'This action is no longer allowed due to time limit.',
      'FORBIDDEN_MENTION_ALL': 'Only owner/admin can use @all.',
      'FORBIDDEN_REVOKE_WINDOW_EXPIRED':
          'This message can no longer be revoked.',
      'MENTIONS_NOT_SUPPORTED_FOR_CONVERSATION_TYPE':
          'Mentions are not supported in this conversation.',
      'MENTION_TARGET_NOT_MEMBER':
          'One or more mentioned users are not group members.',
      'CONTACT_USER_NOT_FRIEND':
          'You can only share contact cards of your friends.',
      'CONTACT_CARD_MEDIA_NOT_ALLOWED':
          'Contact card cannot include media attachments.',
      'CONTACT_USER_REQUIRED': 'Contact user is required.',
      'CANNOT_SHARE_SELF_CONTACT': 'You cannot share your own contact card.',
      'CALL_CALLEE_BUSY': 'The callee is currently busy.',
      'CALL_CALLER_BUSY': 'You are already in another call.',
      'CALL_NO_LONGER_RINGING': 'This call is no longer ringing.',
      'CALL_ALREADY_ENDED': 'This call has already ended.',
      'CALL_NOT_ACTIVE': 'This call is not active.',
      'CALL_NOT_PARTICIPANT': 'You are not a participant of this call.',
    };

    if (errorCode != null && codeMessageMap.containsKey(errorCode)) {
      return codeMessageMap[errorCode]!;
    }

    if (statusCode != null) {
      if (statusCode == 401) {
        return 'Session expired. Please log in again.';
      }
      if (statusCode == 403) {
        return 'You do not have permission for this action.';
      }
      if (statusCode == 404) {
        return 'Resource not found or no longer available.';
      }
      if (statusCode == 409) {
        return 'Conflict detected. Please refresh and try again.';
      }
      if (statusCode >= 500) {
        return 'Server error. Please try again later.';
      }
    }

    if (backendMessage != null && backendMessage.isNotEmpty) {
      return backendMessage;
    }

    return fallback;
  }

  Map<String, dynamic>? _parseBackendError(Object error) {
    if (error is! DioException) {
      return null;
    }

    final response = error.response;
    final data = response?.data;

    String? errorCode;
    String? message;
    int? statusCode = response?.statusCode;

    if (data is Map) {
      final map = data.map((key, value) => MapEntry('$key', value));
      errorCode = _readString(map['errorCode']);
      message = _readString(map['message']);
      final topStatus = map['statusCode'];
      if (topStatus is int) {
        statusCode = topStatus;
      }

      final nested = map['data'];
      if (nested is Map) {
        final nestedMap = nested.map((key, value) => MapEntry('$key', value));
        errorCode ??= _readString(nestedMap['errorCode']);
        message ??= _readString(nestedMap['message']);
      }
    }

    message ??= error.message;
    return <String, dynamic>{
      'errorCode': errorCode,
      'message': message,
      'statusCode': statusCode,
    };
  }

  String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String get _normalizedMuteDuration {
    switch (_muteDuration.trim().toLowerCase()) {
      case '1h':
      case '1':
        return '1';
      case '4h':
      case '4':
        return '4';
      case '8h':
      case '8':
        return '8';
      case '24h':
      case '24':
        return '24';
      case 'until turn back':
      case 'until_turn_back':
      case 'untilturnback':
      case 'forever':
        return 'untilTurnBack';
      default:
        return '1';
    }
  }

  void _applyInviteLinkPayload(dynamic payload) {
    final link = payload is Map<String, dynamic> && payload.containsKey('link')
        ? payload['link']
        : payload;
    if (link is Map) {
      _inviteUrl = _readString(link['url']);
      _inviteExpiresAt = _readString(link['expiresAt']);
    } else {
      _inviteUrl = null;
      _inviteExpiresAt = null;
    }
  }

  void _logDebugError(String scope, Object error, StackTrace stackTrace) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final method = error.requestOptions.method;
      final path = error.requestOptions.path;
      final responseData = error.response?.data;
      final parsed = _parseBackendError(error);

      debugPrint(
        '[GroupManagementPage][$scope] DioException '
        'status=$status method=$method path=$path '
        'code=${parsed?['errorCode']} message=${parsed?['message']} '
        'response=$responseData',
      );
      debugPrint('[GroupManagementPage][$scope] stackTrace=$stackTrace');
      return;
    }

    debugPrint('[GroupManagementPage][$scope] error=$error');
    debugPrint('[GroupManagementPage][$scope] stackTrace=$stackTrace');
  }

  Future<void> _loadJoinRequests() async {
    if (!_isAdminOrOwner) {
      return;
    }
    if (!mounted) return;

    setState(() => _busyRequests = true);
    try {
      final response = await _dio.get(
        _url('/conversations/${widget.conversation.id}/join-requests'),
      );
      final data = _unwrap(response.data);

      List<dynamic> raw = <dynamic>[];
      if (data is List) {
        raw = data;
      } else if (data is Map<String, dynamic> && data['requests'] is List) {
        raw = data['requests'] as List<dynamic>;
      }

      final mapped = raw
          .whereType<Map>()
          .map((item) => item.map((key, value) => MapEntry('$key', value)))
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _joinRequests = mapped;
      });
    } catch (error, stackTrace) {
      _logDebugError('loadJoinRequests', error, stackTrace);
      // Ignore toast here to avoid noisy startup UX.
    } finally {
      if (mounted) {
        setState(() => _busyRequests = false);
      }
    }
  }

  Future<void> _loadInviteLink() async {
    if (!_isAdminOrOwner) return;

    try {
      final response = await _dio.get(
        _url('/conversations/${widget.conversation.id}/invite-link'),
        options: _requestOptions,
      );
      final data = _unwrap(response.data);
      if (!mounted) return;
      setState(() => _applyInviteLinkPayload(data));
    } catch (e, st) {
      _logDebugError('loadInviteLink', e, st);
    }
  }

  Future<void> _loadPolls() async {
    if (!mounted) return;
    setState(() => _busyPolls = true);
    try {
      final mapped = await _groupManagementService.listConversationPolls(
        conversationId: widget.conversation.id,
        includeClosed: false,
      );

      if (!mounted) return;
      setState(() {
        _polls = List<Map<String, dynamic>>.from(mapped)
          ..sort((a, b) {
            DateTime parse(Map<String, dynamic> item) {
              final updated = DateTime.tryParse(
                (item['updatedAt'] ?? '').toString(),
              );
              if (updated != null) return updated;
              final created = DateTime.tryParse(
                (item['createdAt'] ?? '').toString(),
              );
              if (created != null) return created;
              return DateTime.fromMillisecondsSinceEpoch(0);
            }

            return parse(b).compareTo(parse(a));
          });
      });
    } catch (error, stackTrace) {
      _logDebugError('loadPolls', error, stackTrace);
      final parsed = _parseBackendError(error);
      final statusCode = parsed?['statusCode'];
      final backendMessage = (parsed?['message'] as String?)?.trim();

      final statusText = statusCode != null ? ' ($statusCode)' : '';
      final detail = backendMessage?.isNotEmpty == true
          ? backendMessage
          : error.toString();
      _toast('Load polls failed$statusText: $detail');
    } finally {
      if (mounted) {
        setState(() => _busyPolls = false);
      }
    }
  }

  Future<void> _loadAppointments() async {
    if (_appointmentsEndpointUnsupported) {
      return;
    }

    if (!mounted) return;
    setState(() => _busyAppointments = true);
    try {
      final response = await _dio.get(
        _url('/conversations/${widget.conversation.id}/appointments'),
      );
      final data = _unwrap(response.data);

      List<dynamic> raw = <dynamic>[];
      if (data is Map<String, dynamic> && data['appointments'] is List) {
        raw = data['appointments'] as List<dynamic>;
      } else if (data is List) {
        raw = data;
      }

      final mapped = raw
          .whereType<Map>()
          .map((item) => item.map((key, value) => MapEntry('$key', value)))
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _appointments = mapped;
      });
    } catch (error, stackTrace) {
      final parsed = _parseBackendError(error);
      final isEndpointUnsupported =
          parsed?['statusCode'] == 404 &&
          ((parsed?['errorCode'] as String?)?.toUpperCase() ==
                  'RESOURCE_NOT_FOUND' ||
              (parsed?['message'] as String?)?.toLowerCase().contains(
                    'cannot get /conversations/',
                  ) ==
                  true);

      if (isEndpointUnsupported) {
        _appointmentsEndpointUnsupported = true;
        debugPrint(
          '[GroupManagementPage][loadAppointments] Skipped: appointments endpoint is not available in this environment.',
        );
        return;
      }

      _logDebugError('loadAppointments', error, stackTrace);
      // Endpoint may not be enabled in some environments.
    } finally {
      if (mounted) {
        setState(() => _busyAppointments = false);
      }
    }
  }

  Future<void> _updateGroupInfo() async {
    if (!_isAdminOrOwner) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final avatarMediaId = _uploadedAvatarMediaId?.trim() ?? '';

    final body = <String, dynamic>{};
    if (name.isNotEmpty) body['name'] = name;
    if (description.isNotEmpty) body['description'] = description;
    if (avatarMediaId.isNotEmpty) body['avatarMediaId'] = avatarMediaId;

    if (body.isEmpty) {
      _toast('Nothing to update');
      return;
    }

    setState(() => _busyInfo = true);
    try {
      await _dio.patch(
        _url('/conversations/${widget.conversation.id}/info'),
        data: body,
      );
      _toast('Group info updated');
      if (!mounted) return;
      setState(() {
        _pickedAvatarPath = null;
      });
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to update group info.'));
    } finally {
      if (mounted) {
        setState(() => _busyInfo = false);
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    if (!_isAdminOrOwner) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final file = await _mediaService.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (file == null) return;

      final validation = FileUtils.validateAvatarFile(file);
      if (!validation.isValid) {
        _toast(validation.errorMessage ?? 'Invalid avatar image');
        return;
      }

      final size = await file.length();
      if (size <= 0) {
        _toast('Avatar file is empty');
        return;
      }

      setState(() => _busyInfo = true);
      final result = await _chatUiActionsCubit.uploadImageAvatar(
        file.path,
        size,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          _toast(
            failure.message.isNotEmpty
                ? failure.message
                : 'Avatar upload failed',
          );
        },
        (mediaInfo) {
          final mediaId = mediaInfo.mediaId?.trim();
          if (mediaId == null || mediaId.isEmpty) {
            _toast('Avatar upload failed: missing media id');
            return;
          }

          setState(() {
            _pickedAvatarPath = file.path;
            _uploadedAvatarMediaId = mediaId;
          });
          _toast('Avatar uploaded. Save info to apply');
        },
      );
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to pick avatar image.'));
    } finally {
      if (mounted) {
        setState(() => _busyInfo = false);
      }
    }
  }

  Future<void> _updateGroupSettings() async {
    if (!_isAdminOrOwner) return;

    final fullPayload = <String, dynamic>{
      'allowMemberMessage': _allowMemberMessage,
      'isPublic': _isPublic,
      'joinApprovalRequired': _joinApprovalRequired,
    };

    final legacyPayload = <String, dynamic>{
      'allowMemberMessage': _allowMemberMessage,
    };

    setState(() => _busySettings = true);
    try {
      final response = await _dio.patch(
        _url('/conversations/${widget.conversation.id}/settings'),
        data: fullPayload,
        options: _requestOptions,
      );

      _applyConversationSnapshot(response.data);

      // Ensure local screen state remains authoritative after successful update.
      await _syncParticipantsFromServer();
      _toast('Group settings updated');
    } on DioException catch (error, stackTrace) {
      _logDebugError('updateGroupSettings', error, stackTrace);

      final parsed = _parseBackendError(error);
      final message = (parsed?['message'] as String?)?.toLowerCase() ?? '';
      final shouldRetryLegacyPayload =
          parsed?['statusCode'] == 500 &&
          (message.contains('property "ispublic" was not found') ||
              message.contains(
                'property "joinapprovalrequired" was not found',
              ) ||
              message.contains('property "allowmembermessage" was not found'));

      if (!shouldRetryLegacyPayload) {
        _toast(
          _errorMessageFor(error, fallback: 'Failed to update group settings.'),
        );
        return;
      }

      try {
        final fallbackResponse = await _dio.patch(
          _url('/conversations/${widget.conversation.id}/settings'),
          data: legacyPayload,
          options: _requestOptions,
        );

        _applyConversationSnapshot(fallbackResponse.data);
        await _syncParticipantsFromServer();
        _toast(
          'Group settings updated (limited mode: visibility settings are not supported by this server).',
        );
      } on DioException catch (fallbackError, fallbackStackTrace) {
        _logDebugError(
          'updateGroupSettings.fallback',
          fallbackError,
          fallbackStackTrace,
        );
        _toast(
          _errorMessageFor(
            fallbackError,
            fallback: 'Failed to update group settings.',
          ),
        );
      }
    } catch (error, stackTrace) {
      _logDebugError('updateGroupSettings', error, stackTrace);
      _toast(
        _errorMessageFor(error, fallback: 'Failed to update group settings.'),
      );
    } finally {
      if (mounted) {
        setState(() => _busySettings = false);
      }
    }
  }

  Future<void> _updateMemberRole(
    ConversationParticipant member,
    String newRole,
  ) async {
    if (!_isAdminOrOwner) return;

    try {
      await _dio.patch(
        _url(
          '/conversations/${widget.conversation.id}/members/${member.userId}/role',
        ),
        data: {'role': newRole},
      );
      await _syncParticipantsFromServer();
      _toast('Role updated');
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to update member role.'));
    }
  }

  Future<void> _kickMember(ConversationParticipant member) async {
    if (!_isAdminOrOwner) return;

    try {
      await _dio.delete(
        _url(
          '/conversations/${widget.conversation.id}/members/${member.userId}',
        ),
      );
      await _syncParticipantsFromServer();
      _toast('Member removed');
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to remove member.'));
    }
  }

  Future<void> _searchUsersForMemberAdd() async {
    if (!_isAdminOrOwner) return;

    final query = _memberSearchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _hasSearchedMember = false;
        _memberSearchResults = const <MyUser>[];
      });
      return;
    }

    setState(() {
      _busyMemberSearch = true;
      _hasSearchedMember = true;
    });
    try {
      final result = await _chatUiActionsCubit.searchUsersByUsername(
        query,
        page: 1,
        limit: 20,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          _toast(
            failure.message.isNotEmpty ? failure.message : 'Search failed',
          );
          setState(() {
            _memberSearchResults = const <MyUser>[];
          });
        },
        (users) {
          final currentUserId = widget.currentUserId.trim();
          final filtered = users
              .where((user) {
                final id = user.id.trim();
                if (id == currentUserId) return false;
                return true;
              })
              .toList(growable: false);

          setState(() {
            _memberSearchResults = filtered;
          });
        },
      );
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to search users.'));
    } finally {
      if (mounted) {
        setState(() => _busyMemberSearch = false);
      }
    }
  }

  Future<void> _addMember(MyUser user) async {
    if (!_isAdminOrOwner) return;

    final userId = user.id.trim();
    if (userId.isEmpty) {
      _toast('Invalid user');
      return;
    }
    if (_participantIds.contains(userId)) {
      _toast('User is already a member');
      return;
    }

    setState(() => _busyAddMember = true);
    try {
      await _dio.post(
        _url('/conversations/${widget.conversation.id}/members'),
        data: {
          'userIds': <String>[userId],
        },
      );

      if (!mounted) return;

      setState(() {
        _memberSearchResults = _memberSearchResults
            .where((item) => item.id.trim() != userId)
            .toList(growable: false);
      });

      await _syncParticipantsFromServer();

      _toast('Member added');
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to add member.'));
    } finally {
      if (mounted) {
        setState(() => _busyAddMember = false);
      }
    }
  }

  Future<void> _syncParticipantsFromServer() async {
    try {
      final response = await _dio.get(
        _url('/conversations/${widget.conversation.id}'),
        queryParameters: {'avatarVariant': 'thumb'},
        options: _requestOptions,
      );

      if (!mounted) {
        return;
      }

      _applyConversationSnapshot(response.data);
    } catch (error, stackTrace) {
      _logDebugError('syncParticipantsFromServer', error, stackTrace);
      // Keep current in-memory participants if refresh fails.
    }
  }

  void _applyConversationSnapshot(dynamic payload) {
    dynamic current = payload;
    if (current is Map && current['data'] is Map) {
      current = current['data'];
    }
    if (current is! Map) {
      return;
    }

    final normalized = current.map((key, value) => MapEntry('$key', value));
    final participants = _extractParticipants(normalized);

    final allowMemberMessage = normalized['allowMemberMessage'];
    final isPublic = normalized['isPublic'];
    final joinApprovalRequired = normalized['joinApprovalRequired'];

    if (!mounted) {
      return;
    }

    setState(() {
      if (participants.isNotEmpty) {
        _participants = participants;
      }
      if (allowMemberMessage is bool) {
        _allowMemberMessage = allowMemberMessage;
      }
      if (isPublic is bool) {
        _isPublic = isPublic;
      }
      if (joinApprovalRequired is bool) {
        _joinApprovalRequired = joinApprovalRequired;
      }
    });
  }

  List<ConversationParticipant> _extractParticipants(dynamic payload) {
    dynamic current = payload;

    if (current is Map && current['data'] is Map) {
      current = current['data'];
    }

    if (current is! Map) {
      return const <ConversationParticipant>[];
    }

    final rawParticipants = current['participants'];
    if (rawParticipants is! List) {
      return const <ConversationParticipant>[];
    }

    return rawParticipants
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry('$key', value)))
        .map(_toConversationParticipant)
        .where((item) => item.userId.trim().isNotEmpty)
        .toList(growable: false);
  }

  ConversationParticipant _toConversationParticipant(Map<String, dynamic> map) {
    final userId = _readString(map['userId']) ?? _readString(map['id']) ?? '';
    final username = _readString(map['username']) ?? '';
    final displayName =
        _readString(map['displayName']) ?? _readString(map['name']) ?? username;
    final avatarUrl = _readString(map['avatarUrl']) ?? '';
    final role = (_readString(map['role']) ?? 'member').toLowerCase();
    final isActive = map['isActive'] == true;

    return ConversationParticipant(
      userId: userId,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      role: role,
      isActive: isActive,
    );
  }

  Future<void> _createInviteLink() async {
    if (!_isAdminOrOwner) return;

    setState(() => _busyInvite = true);
    var regenerated = (_inviteUrl ?? '').isNotEmpty;
    try {
      final inviteLinkUrl = _url(
        '/conversations/${widget.conversation.id}/invite-link',
      );
      Response<dynamic> response;
      if (regenerated) {
        response = await _dio.put(inviteLinkUrl, options: _requestOptions);
      } else {
        try {
          response = await _dio.post(inviteLinkUrl, options: _requestOptions);
        } on DioException catch (e) {
          if (e.response?.statusCode != 409) rethrow;
          regenerated = true;
          response = await _dio.put(inviteLinkUrl, options: _requestOptions);
        }
      }
      final data = _unwrap(response.data);
      if (!mounted) return;
      setState(() => _applyInviteLinkPayload(data));
      _toast(regenerated ? 'Invite link regenerated' : 'Invite link generated');
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to generate invite link.'));
    } finally {
      if (mounted) {
        setState(() => _busyInvite = false);
      }
    }
  }

  Future<void> _resetInviteLink() async {
    if (!_isAdminOrOwner) return;

    setState(() => _busyInvite = true);
    try {
      await _dio.delete(
        _url('/conversations/${widget.conversation.id}/invite-link'),
        options: _requestOptions,
      );
      if (!mounted) return;
      setState(() {
        _inviteUrl = null;
        _inviteExpiresAt = null;
      });
      _toast('Invite link revoked');
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to revoke invite link.'));
    } finally {
      if (mounted) {
        setState(() => _busyInvite = false);
      }
    }
  }

  Future<void> _createPoll() async {
    if (_openingPollDialog || _submittingPoll) {
      return;
    }

    if (!_isAdminOrOwner) {
      _toast('Only owner/admin can create polls.');
      return;
    }

    if (mounted) {
      setState(() => _openingPollDialog = true);
    }

    Map<String, dynamic>? result;
    try {
      result = await _showCreatePollDialog(context);
    } finally {
      if (mounted) {
        setState(() => _openingPollDialog = false);
      }
    }

    if (result == null) return;

    if (mounted) {
      setState(() => _submittingPoll = true);
    }

    try {
      await _groupManagementService.createPoll(
        conversationId: widget.conversation.id,
        payload: result,
      );
      _toast('Poll created');
      await _loadPolls();
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to create poll.'));
    } finally {
      if (mounted) {
        setState(() => _submittingPoll = false);
      }
    }
  }

  Future<void> _closePoll(String pollId) async {
    try {
      await _groupManagementService.closePoll(
        conversationId: widget.conversation.id,
        pollId: pollId,
      );
      _toast('Poll closed');
      await _loadPolls();
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to close poll.'));
    }
  }

  Future<void> _votePoll(String pollId, List<String> optionIds) async {
    try {
      final updated = await _groupManagementService.votePoll(
        conversationId: widget.conversation.id,
        pollId: pollId,
        optionIds: optionIds,
      );
      if (updated != null) {
        if (!mounted) return;
        setState(() {
          final idx = _polls.indexWhere((p) => p['id'] == pollId);
          if (idx >= 0) _polls[idx] = updated;
        });
      }
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to vote.'));
    }
  }

  Future<void> _createAppointment() async {
    final result = await _showCreateAppointmentDialog(context);
    if (result == null) return;

    try {
      await _dio.post(
        _url('/conversations/${widget.conversation.id}/appointments'),
        data: result,
      );
      _toast('Appointment created');
      await _loadAppointments();
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to create appointment.'));
    }
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    try {
      await _dio.delete(_url('/appointments/$appointmentId'));
      _toast('Appointment deleted');
      await _loadAppointments();
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to delete appointment.'));
    }
  }

  Future<void> _reviewJoinRequest(String requestId, bool approve) async {
    final normalizedRequestId = requestId.trim();
    if (normalizedRequestId.isEmpty) {
      _toast('Invalid request id');
      return;
    }

    final action = approve ? 'approve' : 'reject';
    try {
      final response = await _dio.patch(
        _url(
          '/conversations/${widget.conversation.id}/join-requests/$normalizedRequestId',
        ),
        data: {'action': action},
      );
      debugPrint(
        '[GroupManagementPage] reviewJoinRequest success -> requestId=$normalizedRequestId, action=$action, data=${response.data}',
      );
      _toast(approve ? 'Request approved' : 'Request rejected');
      await _loadJoinRequests();
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to review join request.'));
    }
  }

  // ── Danger zone ─────────────────────────────────────────────────────────

  /// Shows a dialog that lets the user pick between silent leave and leave
  /// with notification. Returns `null` when the user cancels.
  Future<bool?> _askLeaveSilent() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Leave Group'),
          content: const Text('Choose how you want to leave this group.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.notifications_off_outlined, size: 18),
              label: const Text('Leave silently'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, false),
              icon: const Icon(Icons.exit_to_app_outlined, size: 18),
              label: const Text('Leave & notify'),
            ),
          ],
        );
      },
    );
  }

  List<ConversationParticipant> _ownerTransferCandidates() {
    final currentUserId = widget.currentUserId.trim();
    final candidates = _participants
        .where((participant) {
          final userId = participant.userId.trim();
          return userId.isNotEmpty && userId != currentUserId;
        })
        .toList(growable: false);

    int rolePriority(String role) {
      switch (role.trim().toLowerCase()) {
        case 'admin':
          return 0;
        case 'member':
          return 1;
        case 'owner':
          return 2;
        default:
          return 3;
      }
    }

    String displayName(ConversationParticipant participant) {
      final name = participant.displayName.trim();
      if (name.isNotEmpty) {
        return name;
      }
      return participant.username.trim();
    }

    candidates.sort((a, b) {
      final roleCompare = rolePriority(a.role).compareTo(rolePriority(b.role));
      if (roleCompare != 0) {
        return roleCompare;
      }
      return displayName(
        a,
      ).toLowerCase().compareTo(displayName(b).toLowerCase());
    });

    return candidates;
  }

  Future<Map<String, dynamic>?> _askOwnerLeaveSelection() {
    final candidates = _ownerTransferCandidates();
    if (candidates.isEmpty) {
      _toast('No eligible member found to transfer ownership.');
      return Future.value(null);
    }

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        String? selectedUserId = candidates.first.userId.trim();

        String displayName(ConversationParticipant participant) {
          final name = participant.displayName.trim();
          if (name.isNotEmpty) {
            return name;
          }
          final username = participant.username.trim();
          return username.isNotEmpty ? username : participant.userId;
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Leave Group'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select a member to become the new owner before you leave.',
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: candidates.length,
                        itemBuilder: (context, index) {
                          final participant = candidates[index];
                          final userId = participant.userId.trim();
                          final role = participant.role.trim().toLowerCase();
                          return RadioListTile<String>(
                            dense: true,
                            value: userId,
                            groupValue: selectedUserId,
                            onChanged: (value) {
                              setDialogState(() => selectedUserId = value);
                            },
                            title: Text(displayName(participant)),
                            subtitle: Text(role.toUpperCase()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                OutlinedButton.icon(
                  onPressed: selectedUserId == null
                      ? null
                      : () {
                          Navigator.pop(dialogContext, {
                            'transferOwnershipTo': selectedUserId,
                            'silent': true,
                          });
                        },
                  icon: const Icon(Icons.notifications_off_outlined, size: 18),
                  label: const Text('Leave silently'),
                ),
                FilledButton.icon(
                  onPressed: selectedUserId == null
                      ? null
                      : () {
                          Navigator.pop(dialogContext, {
                            'transferOwnershipTo': selectedUserId,
                            'silent': false,
                          });
                        },
                  icon: const Icon(Icons.exit_to_app_outlined, size: 18),
                  label: const Text('Leave & notify'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _leaveGroup() async {
    final isOwner = _myRole == 'owner';
    final payload = <String, dynamic>{};

    if (isOwner) {
      final ownerDecision = await _askOwnerLeaveSelection();
      if (ownerDecision == null) {
        return;
      }

      final transferOwnershipTo =
          ownerDecision['transferOwnershipTo']?.toString().trim() ?? '';
      if (transferOwnershipTo.isEmpty) {
        _toast('Please select a new owner before leaving.');
        return;
      }

      payload['transferOwnershipTo'] = transferOwnershipTo;
      payload['silent'] = ownerDecision['silent'] == true;
    } else {
      final silent = await _askLeaveSilent();
      if (silent == null) {
        return;
      }
      payload['silent'] = silent;
    }

    if (!mounted) return;
    setState(() => _busyDanger = true);
    try {
      await _dio.post(
        _url('/conversations/${widget.conversation.id}/leave'),
        data: payload,
        options: _requestOptions,
      );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to leave the group.'));
    } finally {
      if (mounted) setState(() => _busyDanger = false);
    }
  }

  Future<void> _disbandGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Disband Group'),
          content: const Text(
            'This will permanently delete the group and remove all members. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Disband'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    if (!mounted) return;
    setState(() => _busyDanger = true);
    try {
      await _dio.delete(_url('/conversations/${widget.conversation.id}'));
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to disband the group.'));
    } finally {
      if (mounted) setState(() => _busyDanger = false);
    }
  }

  Future<void> _clearMyMessages() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete My Messages'),
          content: const Text(
            'This will delete all messages you sent in this group from your view. Other members will no longer see them either.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    if (!mounted) return;
    setState(() => _busyDanger = true);
    try {
      await _dio.delete(
        _url('/conversations/${widget.conversation.id}/messages/mine'),
      );
      _toast('All your messages have been deleted.');
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to delete your messages.'));
    } finally {
      if (mounted) setState(() => _busyDanger = false);
    }
  }

  Widget _buildDangerZoneCard(BuildContext context) {
    final isOwner = _myRole == 'owner';
    final colorScheme = Theme.of(context).colorScheme;
    final errorColor = colorScheme.error;
    final onErrorContainer = colorScheme.onErrorContainer;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: errorColor.withValues(alpha: 0.35)),
        ),
        child: ExpansionTile(
          collapsedIconColor: errorColor,
          iconColor: errorColor,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Icon(Icons.warning_amber_rounded, color: errorColor),
          title: Text(
            'Danger Zone',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            // ── Delete my messages (all roles) ──────────────────────────
            _DangerActionTile(
              icon: Icons.delete_sweep_outlined,
              label: 'Delete My Messages',
              description:
                  'Permanently remove all messages you sent in this group.',
              busy: _busyDanger,
              onTap: _clearMyMessages,
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // ── Leave group (owner must choose successor) ────────────────
            _DangerActionTile(
              icon: Icons.exit_to_app_outlined,
              label: 'Leave Group',
              description: isOwner
                  ? 'Before leaving, you must assign a new owner (admins are listed first).'
                  : 'You can choose to leave silently or with a notification.',
              busy: _busyDanger,
              onTap: _leaveGroup,
            ),
            if (isOwner) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _DangerActionTile(
                icon: Icons.delete_forever_outlined,
                label: 'Disband Group',
                description:
                    'Permanently delete this group and remove all members. You cannot undo this.',
                busy: _busyDanger,
                onTap: _disbandGroup,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── End danger zone ───────────────────────────────────────────────────────

  Future<void> _applyMute() async {
    setState(() => _busyNotify = true);
    try {
      await _dio.put(
        _url('/notifications/conversations/${widget.conversation.id}/mute'),
        data: {'duration': _normalizedMuteDuration},
      );
      _toast('Notification mute updated');
    } catch (e) {
      _toast(
        _errorMessageFor(e, fallback: 'Failed to update notification mute.'),
      );
    } finally {
      if (mounted) {
        setState(() => _busyNotify = false);
      }
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final visibleTabs = _visibleTabs;
    final tabViews = <Widget>[
      _buildInfoTab(context),
      _buildMemberTab(context),
      _buildSettingsTab(context),
      if (_isAdminOrOwner) _buildInviteTab(context),
      if (_isAdminOrOwner) _buildRequestTab(context),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Management'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: visibleTabs
              .map((label) => Tab(text: label))
              .toList(growable: false),
        ),
      ),
      body: SafeArea(
        child: TabBarView(controller: _tabController, children: tabViews),
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard(
          context,
          title: 'Group Info',
          subtitle: _isAdminOrOwner
              ? 'Owner/Admin can update name, description, avatarMediaId.'
              : 'Only Owner/Admin can update group info.',
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                enabled: _isAdminOrOwner,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                enabled: _isAdminOrOwner,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ClipOval(
                    child: _pickedAvatarPath != null
                        ? Image.file(
                            File(_pickedAvatarPath!),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          )
                        : (widget.conversation.avatarUrl.trim().isNotEmpty
                              ? Image.network(
                                  widget.conversation.avatarUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    child: const Icon(
                                      Icons.group_outlined,
                                      size: 20,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  child: const Icon(
                                    Icons.group_outlined,
                                    size: 20,
                                  ),
                                )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isAdminOrOwner && !_busyInfo
                          ? _pickAndUploadAvatar
                          : null,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(
                        _uploadedAvatarMediaId == null
                            ? 'Choose Avatar'
                            : 'Avatar ready (${_uploadedAvatarMediaId!.substring(0, _uploadedAvatarMediaId!.length > 8 ? 8 : _uploadedAvatarMediaId!.length)}...)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _isAdminOrOwner && !_busyInfo
                      ? _updateGroupInfo
                      : null,
                  child: _busyInfo
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Info'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          context,
          title: 'Polls',
          subtitle:
              '${_polls.length} poll${_polls.length == 1 ? '' : 's'} in this group',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FilledButton.icon(
                    onPressed:
                        (!_isAdminOrOwner ||
                            _openingPollDialog ||
                            _submittingPoll)
                        ? null
                        : _createPoll,
                    icon: const Icon(Icons.add, size: 18),
                    label: _submittingPoll
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Poll'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _busyPolls ? null : _loadPolls,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              if (_busyPolls) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(),
              ],
              if (_polls.isEmpty && !_busyPolls) ...[
                const SizedBox(height: 12),
                Text(
                  'No polls yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
              ..._polls.map((poll) => _buildPollCard(context, poll)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          context,
          title: 'Appointments',
          subtitle: 'Create / list / delete appointments.',
          child: Column(
            children: [
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _createAppointment,
                    icon: const Icon(Icons.event),
                    label: const Text('Create Appointment'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _busyAppointments ? null : _loadAppointments,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_busyAppointments) const LinearProgressIndicator(),
              ..._appointments.map((appointment) {
                final appointmentId = appointment['id']?.toString() ?? '';
                final title =
                    appointment['title']?.toString() ?? 'Untitled appointment';
                final at = appointment['scheduledAt']?.toString() ?? '';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(title),
                  subtitle: Text(at.isEmpty ? 'No schedule' : at),
                  trailing: appointmentId.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _deleteAppointment(appointmentId),
                          icon: const Icon(Icons.delete_outline),
                        ),
                );
              }),
              if (_appointments.isEmpty && !_busyAppointments)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('No appointments yet.'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPollCard(BuildContext context, Map<String, dynamic> poll) {
    final pollId = poll['id']?.toString() ?? '';
    final question = poll['question']?.toString() ?? 'Untitled poll';
    final isClosed = poll['isClosed'] == true;
    final multipleChoice = poll['multipleChoice'] == true;
    final deadline = poll['deadline']?.toString();
    final rawOptions = poll['options'];
    final options = rawOptions is List
        ? rawOptions
              .whereType<Map>()
              .map((o) => o.map((k, v) => MapEntry('$k', v)))
              .toList()
        : <Map<String, dynamic>>[];

    final currentUserId = widget.currentUserId;
    final totalVotes = options.fold<int>(0, (sum, opt) {
      final voters = opt['voterIds'];
      return sum + (voters is List ? voters.length : 0);
    });

    final myVotedIds = options
        .where((opt) {
          final voters = opt['voterIds'];
          return voters is List && voters.contains(currentUserId);
        })
        .map((opt) => opt['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isClosed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Closed',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Open',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (multipleChoice)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Multiple choices allowed',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            if (deadline != null && deadline.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    () {
                      try {
                        final dt = DateTime.parse(deadline).toLocal();
                        final d = dt.day.toString().padLeft(2, '0');
                        final m = dt.month.toString().padLeft(2, '0');
                        final h = dt.hour.toString().padLeft(2, '0');
                        final min = dt.minute.toString().padLeft(2, '0');
                        return 'Deadline: $d/$m/${dt.year} $h:$min';
                      } catch (_) {
                        return 'Deadline: $deadline';
                      }
                    }(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            ...options.map((opt) {
              final optId = opt['id']?.toString() ?? '';
              final optText = opt['text']?.toString() ?? '';
              final voters = opt['voterIds'];
              final voteCount = voters is List ? voters.length : 0;
              final pct = totalVotes > 0 ? (voteCount / totalVotes) : 0.0;
              final isMyVote = myVotedIds.contains(optId);

              return GestureDetector(
                onTap: isClosed || pollId.isEmpty || optId.isEmpty
                    ? null
                    : () {
                        final newVotes = multipleChoice
                            ? (isMyVote
                                  ? myVotedIds.difference({optId}).toList()
                                  : {...myVotedIds, optId}.toList())
                            : [optId];
                        _votePoll(pollId, newVotes);
                      },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isMyVote
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: isMyVote ? 1.5 : 1,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: pct.clamp(0.0, 1.0),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isMyVote
                                ? colorScheme.primary.withValues(alpha: 0.18)
                                : colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 44,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              if (isMyVote)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  optText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isMyVote
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                '$voteCount  ${(pct * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (totalVotes > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 6),
                child: Text(
                  '$totalVotes vote${totalVotes == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            if (!isClosed && _isAdminOrOwner && pollId.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _closePoll(pollId),
                  icon: const Icon(Icons.lock_outline, size: 14),
                  label: const Text('Close poll'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_isAdminOrOwner)
          _buildSectionCard(
            context,
            title: 'Add Member',
            subtitle: 'Search users by username and add them to this group.',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _memberSearchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchUsersForMemberAdd(),
                        decoration: const InputDecoration(
                          labelText: 'Search users by username',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: _busyMemberSearch
                          ? null
                          : _searchUsersForMemberAdd,
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                  ],
                ),
                if (_busyMemberSearch) ...[
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(),
                ],
                if (_memberSearchResults.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._memberSearchResults.map((user) {
                    final displayName = user.displayName.trim();
                    final nameToShow = displayName.isNotEmpty
                        ? displayName
                        : user.username;
                    final userId = user.id.trim();
                    final isAlreadyMember = _participantIds.contains(userId);
                    final hasValidId = userId.isNotEmpty;
                    final canAdd =
                        !_busyAddMember && hasValidId && !isAlreadyMember;
                    final statusText = isAlreadyMember
                        ? 'Already a member'
                        : !hasValidId
                        ? 'Invalid user id'
                        : '@${user.username}';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(
                          nameToShow.isNotEmpty
                              ? nameToShow[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(nameToShow),
                      subtitle: Text(statusText),
                      trailing: isAlreadyMember
                          ? const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            )
                          : FilledButton.tonalIcon(
                              onPressed: canAdd ? () => _addMember(user) : null,
                              icon: const Icon(Icons.person_add_alt_1_outlined),
                              label: const Text('Add'),
                            ),
                    );
                  }),
                ],
                if (_hasSearchedMember &&
                    !_busyMemberSearch &&
                    _memberSearchResults.isEmpty) ...[
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No users found.'),
                  ),
                ],
              ],
            ),
          ),
        if (_isAdminOrOwner) const SizedBox(height: 14),
        _buildSectionCard(
          context,
          title: 'Member Role Management',
          subtitle: _isAdminOrOwner
              ? 'Owner/Admin can update roles and remove members (server still enforces final RBAC).'
              : 'Only Owner/Admin can manage member roles.',
          child: Column(
            children: _participants
                .map((member) {
                  final isMe =
                      member.userId.trim() == widget.currentUserId.trim();
                  final displayName = member.displayName.trim().isNotEmpty
                      ? member.displayName.trim()
                      : member.username.trim();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(displayName),
                    subtitle: Text(member.role.toUpperCase()),
                    trailing: !_isAdminOrOwner
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton<String>(
                                tooltip: 'Change role',
                                onSelected: (role) =>
                                    _updateMemberRole(member, role),
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'member',
                                    child: Text('Set MEMBER'),
                                  ),
                                  PopupMenuItem(
                                    value: 'admin',
                                    child: Text('Set ADMIN'),
                                  ),
                                  PopupMenuItem(
                                    value: 'owner',
                                    child: Text('Set OWNER'),
                                  ),
                                ],
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.manage_accounts_outlined),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                onPressed: isMe
                                    ? null
                                    : () => _kickMember(member),
                                icon: const Icon(Icons.person_remove_outlined),
                              ),
                            ],
                          ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard(
          context,
          title: 'Group Settings',
          subtitle: _isAdminOrOwner
              ? 'Permission controls for messaging and group visibility.'
              : 'Only Owner/Admin can update these permissions.',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Allow member message'),
                value: _allowMemberMessage,
                onChanged: _isAdminOrOwner
                    ? (value) => setState(() => _allowMemberMessage = value)
                    : null,
              ),
              // isPublic toggle hidden per design decision (logic preserved)
              // SwitchListTile(
              //   contentPadding: EdgeInsets.zero,
              //   title: const Text('Public group'),
              //   value: _isPublic,
              //   onChanged: _isAdminOrOwner
              //       ? (value) => setState(() => _isPublic = value)
              //       : null,
              // ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Join approval required'),
                value: _joinApprovalRequired,
                onChanged: _isAdminOrOwner
                    ? (value) => setState(() => _joinApprovalRequired = value)
                    : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _isAdminOrOwner && !_busySettings
                      ? _updateGroupSettings
                      : null,
                  child: _busySettings
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Settings'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          context,
          title: 'Notifications',
          subtitle: 'Mute notifications for this group.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _muteDuration,
                decoration: const InputDecoration(
                  labelText: 'Mute duration',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('1 hour')),
                  DropdownMenuItem(value: '4', child: Text('4 hours')),
                  DropdownMenuItem(value: '8', child: Text('8 hours')),
                  DropdownMenuItem(value: '24', child: Text('24 hours')),
                  DropdownMenuItem(
                    value: 'untilTurnBack',
                    child: Text('Until turned back on'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _muteDuration = value);
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _busyNotify ? null : _applyMute,
                  child: _busyNotify
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildDangerZoneCard(context),
      ],
    );
  }

  Widget _buildInviteTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard(
          context,
          title: 'Invite Links',
          subtitle: _isAdminOrOwner
              ? 'Owner/Admin can generate, regenerate, and revoke invite links.'
              : 'Only Owner/Admin can manage invite links.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _isAdminOrOwner && !_busyInvite
                        ? _createInviteLink
                        : null,
                    icon: const Icon(Icons.link),
                    label: Text(_inviteUrl == null ? 'Generate' : 'Regenerate'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed:
                        _isAdminOrOwner &&
                            !_busyInvite &&
                            (_inviteUrl ?? '').isNotEmpty
                        ? _resetInviteLink
                        : null,
                    icon: const Icon(Icons.link_off_outlined),
                    label: const Text('Revoke'),
                  ),
                ],
              ),
              if (!_busyInvite && _inviteUrl == null) ...[
                const SizedBox(height: 12),
                const Text('No active invite link. Generate one to share.'),
              ],
              if (_busyInvite) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(),
              ],
              if (_inviteUrl != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: QrImageView(
                    data: _inviteUrl!,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(_inviteUrl!),
                if ((_inviteExpiresAt ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Expires: ${_inviteExpiresAt!}'),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _inviteUrl!));
                        _toast('Invite link copied');
                      },
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy Link'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (_) => ShareInviteLinkDialog(
                            inviteUrl: _inviteUrl!,
                            groupName: widget.conversation.name,
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share Link'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestTab(BuildContext context) {
    if (!_isAdminOrOwner) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Only Owner/Admin can view and review join requests.'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard(
          context,
          title: 'Join Requests',
          subtitle: 'Approve or reject requests for join-approval groups.',
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _busyRequests ? null : _loadJoinRequests,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ),
              if (_busyRequests) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(),
              ],
              const SizedBox(height: 8),
              ..._joinRequests.map((request) {
                final requestId = request['id']?.toString() ?? '';
                final userId = request['userId']?.toString() ?? '';
                final message = request['requestMessage']?.toString() ?? '';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(userId.isEmpty ? 'Unknown user' : userId),
                  subtitle: Text(message.isEmpty ? 'No message' : message),
                  trailing: requestId.isEmpty
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _reviewJoinRequest(requestId, true),
                              child: const Text('Approve'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  _reviewJoinRequest(requestId, false),
                              child: const Text('Reject'),
                            ),
                          ],
                        ),
                );
              }),
              if (_joinRequests.isEmpty && !_busyRequests)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('No pending requests.'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── Danger Zone action tile ────────────────────────────────────────────────

class _DangerActionTile extends StatelessWidget {
  const _DangerActionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.busy,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: errorColor),
      title: Text(
        label,
        style: TextStyle(color: errorColor, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(description, style: Theme.of(context).textTheme.bodySmall),
      trailing: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.chevron_right, color: errorColor),
      onTap: busy ? null : onTap,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

Future<Map<String, dynamic>?> _showCreatePollDialog(
  BuildContext context,
) async {
  final questionController = TextEditingController();
  final optionControllers = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ];
  bool multipleChoice = false;
  DateTime? deadline;

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (ctx, setS) {
          const maxOptions = 10;

          void addOption() {
            if (optionControllers.length < maxOptions) {
              setS(() => optionControllers.add(TextEditingController()));
            }
          }

          void removeOption(int index) {
            if (optionControllers.length > 2) {
              optionControllers[index].dispose();
              setS(() => optionControllers.removeAt(index));
            }
          }

          Future<void> pickDeadline() async {
            final now = DateTime.now();
            final pickedDate = await showDatePicker(
              context: ctx,
              initialDate: deadline ?? now.add(const Duration(days: 1)),
              firstDate: now,
              lastDate: now.add(const Duration(days: 365)),
              useRootNavigator: true,
            );
            if (pickedDate == null) return;
            if (!ctx.mounted) return;
            final pickedTime = await showTimePicker(
              context: ctx,
              initialTime: TimeOfDay.fromDateTime(
                deadline ?? now.add(const Duration(hours: 1)),
              ),
              useRootNavigator: true,
            );
            if (pickedTime == null) return;
            setS(() {
              deadline = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            });
          }

          String formatDeadline(DateTime dt) {
            final d = dt.day.toString().padLeft(2, '0');
            final m = dt.month.toString().padLeft(2, '0');
            final y = dt.year;
            final h = dt.hour.toString().padLeft(2, '0');
            final min = dt.minute.toString().padLeft(2, '0');
            return '$d/$m/$y  $h:$min';
          }

          final colorScheme = Theme.of(ctx).colorScheme;
          final labelStyle = TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: colorScheme.onSurface.withValues(alpha: 0.55),
          );
          final fieldDecoration = InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          );

          return AlertDialog(
            title: Text(
              'Create Poll',
              style: Theme.of(
                ctx,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 520,
                maxHeight: MediaQuery.sizeOf(ctx).height * 0.62,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('QUESTION', style: labelStyle),
                    const SizedBox(height: 6),
                    TextField(
                      controller: questionController,
                      decoration: fieldDecoration.copyWith(
                        hintText: 'Ask something...',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('OPTIONS', style: labelStyle),
                    const SizedBox(height: 6),
                    ...List.generate(optionControllers.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: optionControllers[i],
                                decoration: fieldDecoration.copyWith(
                                  hintText: 'Option ${i + 1}',
                                ),
                              ),
                            ),
                            if (optionControllers.length > 2) ...[
                              const SizedBox(width: 4),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                                onPressed: () => removeOption(i),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    if (optionControllers.length < maxOptions)
                      GestureDetector(
                        onTap: addOption,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Add option (${optionControllers.length}/$maxOptions)',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => setS(() => multipleChoice = !multipleChoice),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: multipleChoice,
                              onChanged: (v) =>
                                  setS(() => multipleChoice = v ?? false),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Multiple choices'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('DEADLINE (OPTIONAL)', style: labelStyle),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: pickDeadline,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                deadline != null
                                    ? formatDeadline(deadline!)
                                    : 'dd/mm/yyyy  --:--',
                                style: TextStyle(
                                  color: deadline != null
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurface.withValues(
                                          alpha: 0.4,
                                        ),
                                ),
                              ),
                            ),
                            if (deadline != null)
                              GestureDetector(
                                onTap: () => setS(() => deadline = null),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 20,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final question = questionController.text.trim();
                  final options = optionControllers
                      .map((c) => c.text.trim())
                      .where((t) => t.isNotEmpty)
                      .toList(growable: false);
                  if (question.isEmpty || options.length < 2) {
                    return;
                  }
                  Navigator.of(dialogContext).pop({
                    'question': question,
                    'options': options,
                    'multipleChoice': multipleChoice,
                    if (deadline != null)
                      'deadline': deadline!.toUtc().toIso8601String(),
                  });
                },
                child: const Text('Create Poll'),
              ),
            ],
          );
        },
      );
    },
  );

  for (final c in optionControllers) {
    c.dispose();
  }
  questionController.dispose();
  return result;
}

Future<Map<String, dynamic>?> _showCreateAppointmentDialog(
  BuildContext context,
) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Create Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                return;
              }

              Navigator.pop(dialogContext, {
                'title': title,
                'description': descriptionController.text.trim(),
                'location': locationController.text.trim(),
                // Default: schedule 1 hour from now; user can edit from server UI later.
                'scheduledAt': DateTime.now()
                    .toUtc()
                    .add(const Duration(hours: 1))
                    .toIso8601String(),
              });
            },
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
}
