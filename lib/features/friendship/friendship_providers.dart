import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/friendship/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data Sources
final friendshipRemoteDataSourceProvider = Provider<FriendshipRemoteDataSource>((ref) {
  return FriendshipRemoteDataSourceImpl(ref.watch(authDioProvider));
});

final friendshipDaoProvider = Provider<FriendshipDao>((ref) {
  return DriftFriendshipDaoImpl(ref.watch(databaseProvider));
});

// Repository
final friendshipRepositoryProvider = Provider<FriendshipRepository>((ref) {
  return FriendshipRepositoryImpl(
    remoteDataSource: ref.watch(friendshipRemoteDataSourceProvider),
    friendshipDao: ref.watch(friendshipDaoProvider),
    localUserMapper: ref.watch(localUserMapperProvider),
    authPrefDataSource: ref.watch(authPrefsDtsProvider),
    authRemoteRepository: ref.watch(authRemoteRepoProvider),
  );
});

// Use Cases
final getFriendshipStatusUseCaseProvider = Provider<GetFriendshipStatusUseCase>((ref) {
  return GetFriendshipStatusUseCase(ref.watch(friendshipRepositoryProvider));
});

final sendFriendRequestUseCaseProvider = Provider<SendFriendRequestUseCase>((ref) {
  return SendFriendRequestUseCase(ref.watch(friendshipRepositoryProvider));
});

final acceptFriendRequestUseCaseProvider = Provider<AcceptFriendRequestUseCase>((ref) {
  return AcceptFriendRequestUseCase(ref.watch(friendshipRepositoryProvider));
});

final rejectFriendRequestUseCaseProvider = Provider<RejectFriendRequestUseCase>((ref) {
  return RejectFriendRequestUseCase(ref.watch(friendshipRepositoryProvider));
});

final getPendingRequestsUseCaseProvider = Provider<GetPendingRequestsUseCase>((ref) {
  return GetPendingRequestsUseCase(ref.watch(friendshipRepositoryProvider));
});

final getFriendsListUseCaseProvider = Provider<GetFriendsListUseCase>((ref) {
  return GetFriendsListUseCase(ref.watch(friendshipRepositoryProvider));
});

final syncFriendshipsToLocalUseCaseProvider = Provider<SyncFriendshipsToLocalUseCase>((ref) {
  return SyncFriendshipsToLocalUseCase(ref.watch(friendshipRepositoryProvider));
});

final removeFriendshipUseCaseProvider = Provider<RemoveFriendshipUseCase>((ref) {
  return RemoveFriendshipUseCase(ref.watch(friendshipRepositoryProvider));
});

final blockUserUseCaseProvider = Provider<BlockUserUseCase>((ref) {
  return BlockUserUseCase(ref.watch(friendshipRepositoryProvider));
});

final unblockUserUseCaseProvider = Provider<UnblockUserUseCase>((ref) {
  return UnblockUserUseCase(ref.watch(friendshipRepositoryProvider));
});
