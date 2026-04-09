import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/chat/data/datasource/api/chat_service_impl.dart';
import 'package:flutter_chat/features/chat/data/repositories/chat_repo_impl.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:riverpod/riverpod.dart';

//datasource
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatServiceImpl(ref.read(authDioProvider));
});

//repo
final chatRepoProvider = Provider<ChatRepository>((ref) {
  return ChatRepoImpl(ref.read(chatServiceProvider));
});

//use cases
final fetchConversationUseCaseProvider = Provider<FetchConversationUseCase>((ref) {
  return FetchConversationUseCase(ref.read(chatRepoProvider));
});

