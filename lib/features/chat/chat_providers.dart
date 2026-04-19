import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/chat/data/datasource/api/chat_service_impl.dart';
import 'package:flutter_chat/features/chat/data/repositories/chat_repo_impl.dart';
import 'package:flutter_chat/features/chat/domain/usecases/get_sticker_packages_usecase.dart';
import 'package:flutter_chat/features/chat/domain/usecases/get_stickers_in_package_usecase.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:riverpod/riverpod.dart';

//datasource
final chatServiceProvider = Provider<ChatService>((ref) {
  // authDioProvider already includes auth interceptor/token refresh behavior.
  return ChatServiceImpl(
    ref.watch(authDioProvider),
    ref.read(realtimeGatewayServiceProvider),
  );
});

final conversationDaoProvider = Provider<ConversationDao>((ref) {
  return DriftConversationDaoImpl(ref.watch(databaseProvider));
});

final messageDaoProvider = Provider<MessageDao>((ref) {
  return DriftMessageDaoImpl(ref.watch(databaseProvider));
});

final apiConversationMapperProvider = Provider<ApiConversationMapper>((ref) {
  return ApiConversationMapper();
});

final apiMessageMapperProvider = Provider<ApiMessageMapper>((ref) {
  return ApiMessageMapper();
});

final localConversationMapperProvider = Provider<LocalConversationMapper>((ref) {
  return LocalConversationMapper();
});

final localMessageMapperProvider = Provider<LocalMessageMapper>((ref) {
  return LocalMessageMapper();
});

//repo
final chatRepoProvider = Provider<ChatRepository>((ref) {
  return ChatRepoImpl(
    chatService: ref.read(chatServiceProvider),
    conversationDao: ref.read(conversationDaoProvider),
    messageDao: ref.read(messageDaoProvider),
    apiConversationMapper: ref.read(apiConversationMapperProvider),
    apiMessageMapper: ref.read(apiMessageMapperProvider),
    localConversationMapper: ref.read(localConversationMapperProvider),
    localMessageMapper: ref.read(localMessageMapperProvider),
  );
});

//use cases
final fetchConversationUseCaseProvider = Provider<FetchConversationUseCase>((ref) {
  return FetchConversationUseCase(ref.read(chatRepoProvider));
});

final joinConversationUseCaseProvider = Provider<JoinConversationUseCase>((ref) {
  return JoinConversationUseCase(ref.read(chatRepoProvider));
});

final fetchMessagesUseCaseProvider = Provider<FetchMessagesUseCase>((ref) {
  return FetchMessagesUseCase(ref.read(chatRepoProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.read(chatRepoProvider));
});

final watchConversationsLocalUseCaseProvider = Provider<WatchConversationsLocalUseCase>((ref) {
  return WatchConversationsLocalUseCase(ref.read(chatRepoProvider));
});

final watchMessagesLocalUseCaseProvider = Provider<WatchMessagesLocalUseCase>((ref) {
  return WatchMessagesLocalUseCase(ref.read(chatRepoProvider));
});

final getStickerPackagesUseCaseProvider = Provider<GetStickerPackagesUseCase>((ref) {
  return GetStickerPackagesUseCase(ref.read(chatRepoProvider));
});

final getStickersInPackageUseCaseProvider = Provider<GetStickersInPackageUseCase>((ref) {
  return GetStickersInPackageUseCase(ref.read(chatRepoProvider));
});
