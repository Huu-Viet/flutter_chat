import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/message.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:uuid/uuid.dart';

class ShareInviteState extends Equatable {
  final String? currentUserId;
  final bool isSending;
  final String? errorMessage;
  final int? sentCount;

  const ShareInviteState({
    this.currentUserId,
    this.isSending = false,
    this.errorMessage,
    this.sentCount,
  });

  ShareInviteState copyWith({
    String? currentUserId,
    bool? isSending,
    Object? errorMessage = _sentinel,
    Object? sentCount = _sentinel,
  }) {
    return ShareInviteState(
      currentUserId: currentUserId ?? this.currentUserId,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      sentCount: sentCount == _sentinel ? this.sentCount : sentCount as int?,
    );
  }

  @override
  List<Object?> get props => [currentUserId, isSending, errorMessage, sentCount];
}

const _sentinel = Object();

class ShareInviteCubit extends Cubit<ShareInviteState> {
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;
  final SendMessageUseCase sendMessageUseCase;

  ShareInviteCubit({
    required this.getCurrentUserIdUseCase,
    required this.sendMessageUseCase,
  }) : super(const ShareInviteState());

  Future<void> loadCurrentUser() async {
    final result = await getCurrentUserIdUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.message,
        ),
      ),
      (id) => emit(state.copyWith(currentUserId: id.trim(), errorMessage: null)),
    );
  }

  Future<void> sendInvite({
    required Set<String> targetConversationIds,
    required String shareText,
  }) async {
    if (targetConversationIds.isEmpty || state.isSending) {
      return;
    }

    emit(state.copyWith(isSending: true, errorMessage: null, sentCount: null));

    final senderId = state.currentUserId?.trim() ?? '';
    final now = DateTime.now();
    final uuid = const Uuid();

    for (final conversationId in targetConversationIds) {
      final messageId = uuid.v4();
      final msg = TextMessage(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        offset: null,
        isDeleted: false,
        serverId: messageId,
        createdAt: now,
        editedAt: null,
        text: shareText,
      );
      final sendResult = await sendMessageUseCase(message: msg);
      final failure = sendResult.fold((f) => f, (_) => null);
      if (failure != null) {
        emit(state.copyWith(isSending: false, errorMessage: failure.message));
        return;
      }
    }

    emit(state.copyWith(isSending: false, sentCount: targetConversationIds.length));
  }

  void clearFeedback() {
    emit(state.copyWith(errorMessage: null, sentCount: null));
  }
}
