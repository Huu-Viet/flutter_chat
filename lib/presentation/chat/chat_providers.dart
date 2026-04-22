import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/upload_media/upload_media_providers.dart';
import 'package:flutter_chat/presentation/chat/blocs/chat_bloc.dart';
import 'package:riverpod/riverpod.dart';

final chatBlocProvider = Provider<ChatBloc>((ref) {
  final bloc = ChatBloc(
    fetchMessagesUseCase: ref.read(fetchMessagesUseCaseProvider),
    getConversationUseCase: ref.read(getConversationUseCaseProvider),
    watchMessagesLocalUseCase: ref.read(watchMessagesLocalUseCaseProvider),
    sendMessageUseCase: ref.read(sendMessageUseCaseProvider),
    editMessageUseCase: ref.read(editMessageUseCaseProvider),
    forwardMessageUseCase: ref.read(forwardMessageUseCaseProvider),
    hiddenForMeUseCase: ref.read(hiddenForMeUseCaseProvider),
    revokeMessageUseCase: ref.read(revokeMessageUseCaseProvider),
    updateMessageReactionUseCase: ref.read(updateMessageReactionUseCaseProvider),
    getCurrentUserIdUseCase: ref.read(getCurrentUserIdUseCaseProvider),
    uploadMediaUseCase: ref.read(uploadMediaUseCaseProvider),
    getUrlByMediaIdUseCase: ref.read(getImageUrlByMediaIdUseCaseProvider),
    getMediaPlayInfoUseCase: ref.read(getMediaPlayInfoUseCaseProvider),
    getMediaUrlByMediaIdUseCase: ref.read(getMediaUrlByMediaIdUseCaseProvider),
    watchConversationsLocalUseCase: ref.read(watchConversationsLocalUseCaseProvider),
    audioCacheDao: ref.read(audioCacheDaoProvider),
  );

  ref.onDispose(bloc.close);
  return bloc;
});