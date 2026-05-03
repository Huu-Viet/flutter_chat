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
  String? _pickedAvatarPath;
  String? _uploadedAvatarMediaId;

  bool _busyInfo = false;
  bool _busySettings = false;
  bool _busyInvite = false;
  bool _busyRequests = false;
  bool _busyPolls = false;
  bool _busyAppointments = false;
  bool _busyNotify = false;
  bool _busyDanger = false;
  bool _busyMemberSearch = false;
  bool _busyAddMember = false;
  bool _hasSearchedMember = false;

  String? _inviteUrl;
  String? _inviteExpiresAt;
  String _muteDuration = 'off';

  List<Map<String, dynamic>> _joinRequests = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _polls = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _appointments = <Map<String, dynamic>>[];
  List<MyUser> _memberSearchResults = const <MyUser>[];

  @override
  void initState() {
    super.initState();
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

    _syncParticipantsFromServer();
    _loadJoinRequests();
    _loadPolls();
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _memberSearchController.dispose();
    super.dispose();
  }

  Dio get _dio => ref.read(authDioProvider);
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  String _url(String path) {
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$base$normalizedPath';
  }

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

  Future<void> _loadJoinRequests() async {
    if (!_isAdminOrOwner) {
      return;
    }

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
    } catch (_) {
      // Ignore here to avoid noisy startup toasts.
    } finally {
      if (mounted) {
        setState(() => _busyRequests = false);
      }
    }
  }

  Future<void> _loadPolls() async {
    setState(() => _busyPolls = true);
    try {
      final response = await _dio.get(
        _url('/conversations/${widget.conversation.id}/polls'),
      );
      final data = _unwrap(response.data);

      List<dynamic> raw = <dynamic>[];
      if (data is Map<String, dynamic> && data['polls'] is List) {
        raw = data['polls'] as List<dynamic>;
      } else if (data is List) {
        raw = data;
      }

      final mapped = raw
          .whereType<Map>()
          .map((item) => item.map((key, value) => MapEntry('$key', value)))
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _polls = mapped;
      });
    } catch (_) {
      // Endpoint may not be enabled in some environments.
    } finally {
      if (mounted) {
        setState(() => _busyPolls = false);
      }
    }
  }

  Future<void> _loadAppointments() async {
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
    } catch (_) {
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
      final result = await ref.read(uploadMediaUseCaseProvider)(
        file.path,
        'image',
        size,
        null,
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

    setState(() => _busySettings = true);
    try {
      await _dio.patch(
        _url('/conversations/${widget.conversation.id}/settings'),
        data: {
          'allowMemberMessage': _allowMemberMessage,
          'isPublic': _isPublic,
          'joinApprovalRequired': _joinApprovalRequired,
        },
      );
      _toast('Group settings updated');
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to update group settings.'));
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
      final result = await ref.read(searchUsersByUsernameUseCaseProvider)(
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
      );

      final participants = _extractParticipants(response.data);
      if (participants.isEmpty || !mounted) {
        return;
      }

      setState(() {
        _participants = participants;
      });
    } catch (_) {
      // Keep current in-memory participants if refresh fails.
    }
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
    try {
      final response = await _dio.post(
        _url('/conversations/${widget.conversation.id}/invite-link'),
      );
      final data = _unwrap(response.data);
      if (!mounted) return;
      setState(() {
        _inviteUrl = data is Map<String, dynamic>
            ? data['url']?.toString()
            : null;
        _inviteExpiresAt = data is Map<String, dynamic>
            ? data['expiresAt']?.toString()
            : null;
      });
      _toast('Invite link generated');
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
      // Preferred by FE guide
      await _dio.post(
        _url('/conversations/${widget.conversation.id}/invite-link/reset'),
      );
      if (!mounted) return;
      setState(() {
        _inviteUrl = null;
        _inviteExpiresAt = null;
      });
      _toast('Invite links reset');
    } catch (_) {
      try {
        // Fallback for older contract variant
        await _dio.delete(
          _url('/conversations/${widget.conversation.id}/invite-link'),
        );
        if (!mounted) return;
        setState(() {
          _inviteUrl = null;
          _inviteExpiresAt = null;
        });
        _toast('Invite links reset');
      } catch (e) {
        _toast(_errorMessageFor(e, fallback: 'Failed to reset invite links.'));
      }
    } finally {
      if (mounted) {
        setState(() => _busyInvite = false);
      }
    }
  }

  Future<void> _createPoll() async {
    final result = await _showCreatePollDialog(context);
    if (result == null) return;

    try {
      await _dio.post(
        _url('/conversations/${widget.conversation.id}/polls'),
        data: result,
      );
      _toast('Poll created');
      await _loadPolls();
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to create poll.'));
    }
  }

  Future<void> _closePoll(String pollId) async {
    try {
      await _dio.post(
        _url('/conversations/${widget.conversation.id}/polls/$pollId/close'),
      );
      _toast('Poll closed');
      await _loadPolls();
    } catch (e) {
      _toast(_errorMessageFor(e, fallback: 'Failed to close poll.'));
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

  Future<void> _leaveGroup() async {
    final silent = await _askLeaveSilent();
    if (silent == null) return; // cancelled

    if (!mounted) return;
    setState(() => _busyDanger = true);
    try {
      await _dio.post(
        _url('/conversations/${widget.conversation.id}/leave'),
        data: {'silent': silent},
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
            // ── Leave (non-owners) or Disband (owner) ───────────────────
            if (!isOwner)
              _DangerActionTile(
                icon: Icons.exit_to_app_outlined,
                label: 'Leave Group',
                description:
                    'You can choose to leave silently or with a notification.',
                busy: _busyDanger,
                onTap: _leaveGroup,
              )
            else
              _DangerActionTile(
                icon: Icons.delete_forever_outlined,
                label: 'Disband Group',
                description:
                    'Permanently delete this group and remove all members. You cannot undo this.',
                busy: _busyDanger,
                onTap: _disbandGroup,
              ),
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
        data: {'duration': _muteDuration},
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
          subtitle: 'Create / list / close polls.',
          child: Column(
            children: [
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _createPoll,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Poll'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _busyPolls ? null : _loadPolls,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_busyPolls) const LinearProgressIndicator(),
              ..._polls.map((poll) {
                final pollId = poll['id']?.toString() ?? '';
                final question =
                    poll['question']?.toString() ?? 'Untitled poll';
                final isClosed = poll['isClosed'] == true;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(question),
                  subtitle: Text(isClosed ? 'Closed' : 'Open'),
                  trailing: isClosed
                      ? null
                      : TextButton(
                          onPressed: pollId.isEmpty
                              ? null
                              : () => _closePoll(pollId),
                          child: const Text('Close'),
                        ),
                );
              }),
              if (_polls.isEmpty && !_busyPolls)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('No polls yet.'),
                ),
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
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Public group'),
                value: _isPublic,
                onChanged: _isAdminOrOwner
                    ? (value) => setState(() => _isPublic = value)
                    : null,
              ),
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
                      : const Text('Save Settings'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          context,
          title: 'Notification Mute',
          subtitle: 'All members can configure their own mute duration.',
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey<String>(_muteDuration),
                  initialValue: _muteDuration,
                  decoration: const InputDecoration(labelText: 'Mute duration'),
                  items: const [
                    DropdownMenuItem(value: '1h', child: Text('1 hour')),
                    DropdownMenuItem(value: '4h', child: Text('4 hours')),
                    DropdownMenuItem(value: '8h', child: Text('8 hours')),
                    DropdownMenuItem(value: '24h', child: Text('24 hours')),
                    DropdownMenuItem(value: 'forever', child: Text('Forever')),
                    DropdownMenuItem(value: 'off', child: Text('Off')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _muteDuration = value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _busyNotify ? null : _applyMute,
                child: _busyNotify
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Apply'),
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
              ? 'Owner/Admin can generate and reset invite links.'
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
                    label: const Text('Generate'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _isAdminOrOwner && !_busyInvite
                        ? _resetInviteLink
                        : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ],
              ),
              if (_busyInvite) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(),
              ],
              if (_inviteUrl != null) ...[
                const SizedBox(height: 12),
                SelectableText(_inviteUrl!),
                if ((_inviteExpiresAt ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Expires: ${_inviteExpiresAt!}'),
                ],
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _inviteUrl!));
                    _toast('Invite link copied');
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy Link'),
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
  final optionsController = TextEditingController();
  bool multipleChoice = false;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create Poll'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: optionsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Options (one per line)',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: multipleChoice,
                  onChanged: (value) => setState(() => multipleChoice = value),
                  title: const Text('Multiple choice'),
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
                  final question = questionController.text.trim();
                  final options = optionsController.text
                      .split('\n')
                      .map((line) => line.trim())
                      .where((line) => line.isNotEmpty)
                      .toList(growable: false);

                  if (question.isEmpty || options.length < 2) {
                    return;
                  }

                  Navigator.pop(dialogContext, {
                    'question': question,
                    'options': options,
                    'multipleChoice': multipleChoice,
                  });
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      );
    },
  );
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
