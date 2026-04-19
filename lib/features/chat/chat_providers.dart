import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/chat/data/datasource/api/chat_service_impl.dart';
import 'package:flutter_chat/features/chat/data/repositories/chat_repo_impl.dart';
import 'package:flutter_chat/features/chat/data/mappers/api_sticker_item_mapper.dart';
import 'package:flutter_chat/features/chat/data/mappers/api_sticker_package_mapper.dart';
import 'package:flutter_chat/features/chat/domain/usecases/get_sticker_packages_usecase.dart';
import 'package:flutter_chat/features/chat/domain/usecases/get_stickers_in_package_usecase.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/features/chat/domain/usecases/get_stickers_in_package_usecase.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:riverpod/riverpod.dart';

//datasource
final chatServiceProvider = Provider<ChatService>((ref) {
  // authDioProvider already includes auth interceptor/token refresh behavior.
  return ChatServiceImpl(
    ref.read(authDioProvider),
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

final stickerPackageMapperProvider = Provider<ApiStickerPackageMapper>((ref) {
  return ApiStickerPackageMapper();
});

final stickerItemMapperProvider = Provider<ApiStickerItemMapper>((ref) {
  return ApiStickerItemMapper();
});

final localStickerPackageMapperProvider = Provider<LocalStickerPackageMapper>((ref) {
  return LocalStickerPackageMapper();
});

final localStickerItemMapperProvider = Provider<LocalStickerItemMapper>((ref) {
  return LocalStickerItemMapper();
});

final stickerPackageDaoProvider = Provider<StickerPackageDao>((ref) {
  return DriftStickerPackageDaoImpl(ref.watch(databaseProvider));
});

final stickerItemDaoProvider = Provider<StickerItemDao>((ref) {
  return DriftStickerItemDaoImpl(ref.watch(databaseProvider));
});

//repo
final chatRepoProvider = Provider<ChatRepository>((ref) {
  return ChatRepoImpl(
    chatService: ref.read(chatServiceProvider),
    conversationDao: ref.read(conversationDaoProvider),
    messageDao: ref.read(messageDaoProvider),
    stickerPackageDao: ref.read(stickerPackageDaoProvider),
    stickerItemDao: ref.read(stickerItemDaoProvider),
    apiConversationMapper: ref.read(apiConversationMapperProvider),
    apiMessageMapper: ref.read(apiMessageMapperProvider),
    localConversationMapper: ref.read(localConversationMapperProvider),
    localMessageMapper: ref.read(localMessageMapperProvider),
    stickerPackageMapper: ref.read(stickerPackageMapperProvider),
    stickerItemMapper: ref.read(stickerItemMapperProvider),
    localStickerPackageMapper: ref.read(localStickerPackageMapperProvider),
    localStickerItemMapper: ref.read(localStickerItemMapperProvider),
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
