import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/call/data/api/call_remote_ds.dart';
import 'package:flutter_chat/features/call/data/repo_impl/call_repo_impl.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:riverpod/riverpod.dart';

final callRemoteDataSourceProvider = Provider<CallRemoteDataSource>((ref) {
  return FirebaseCallRemoteDS(
      databaseRef: ref.watch(firebaseDatabaseRefProvider)
  );
});

final callRepoProvider = Provider<CallRepository>((ref) {
  return CallRepoImpl(ref.watch(callRemoteDataSourceProvider));
});

final sendCallRequestUseCaseProvider = Provider<SendCallRequestUseCase>((ref) {
  return SendCallRequestUseCase(ref.watch(callRepoProvider));
});

