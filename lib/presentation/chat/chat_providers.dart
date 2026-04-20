import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/upload_media/upload_media_providers.dart';
import 'package:flutter_chat/presentation/chat/blocs/chat_bloc.dart';
import 'package:riverpod/riverpod.dart';

final chatBlocProvider = Provider<ChatBloc>((ref) {
  final bloc = ChatBloc(
    fetchMessagesUseCase: ref.read(fetchMessagesUseCaseProvider),
    watchMessagesLocalUseCase: ref.read(watchMessagesLocalUseCaseProvider),
    sendMessageUseCase: ref.read(sendMessageUseCaseProvider),
    editMessageUseCase: ref.read(editMessageUseCaseProvider),
    deleteMessageUseCase: ref.read(deleteMessageUseCaseProvider),
    updateMessageReactionUseCase: ref.read(updateMessageReactionUseCaseProvider),
    getCurrentUserIdUseCase: ref.read(getCurrentUserIdUseCaseProvider),
    uploadMediaUseCase: ref.read(uploadMediaUseCaseProvider),
    getImageUrlByMediaIdUseCase: ref.read(getImageUrlByMediaIdUseCaseProvider),
    watchConversationsLocalUseCase: ref.read(watchConversationsLocalUseCaseProvider),
  );

  ref.onDispose(bloc.close);
  return bloc;
});