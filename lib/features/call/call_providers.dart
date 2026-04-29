// call services providers
import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_accept_mapper.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_mapper.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_token_mapper.dart';
import 'package:flutter_chat/features/call/data/repo_impl/call_repo_impl.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final callServiceProviders = Provider<CallRemoteDataSource>((ref) {
  return CallRemoteDSImpl(
    dio: ref.watch(authDioProvider),
    realtimeGateway: ref.watch(realtimeGatewayServiceProvider),
  );
});

final apiCallMapperProvider = Provider<ApiCallMapper>((ref) {
  return ApiCallMapper();
});

final apiCallAcceptMapperProvider = Provider<ApiCallAcceptMapper>((ref) {
  return ApiCallAcceptMapper();
});

final apiCallTokenMapperProvider = Provider<ApiCallTokenMapper>((ref) {
  return ApiCallTokenMapper();
});

final callRepositoryProvider = Provider<CallRepository>((ref) {
  return CallRepoImpl(
    callRemoteDataSource: ref.read(callServiceProviders),
    apiCallMapper: ref.read(apiCallMapperProvider),
    apiCallAcceptMapper: ref.read(apiCallAcceptMapperProvider),
    apiCallTokenMapper: ref.read(apiCallTokenMapperProvider),
  );
});

final acceptCallUseCaseProvider = Provider<AcceptCallUseCase>((ref) {
  return AcceptCallUseCase(ref.read(callRepositoryProvider));
});

final acceptIncomingCallUseCaseProvider = Provider<AcceptIncomingCallUseCase>((
  ref,
) {
  return AcceptIncomingCallUseCase(ref.read(callRepositoryProvider));
});

final startOutgoingCallUseCaseProvider = Provider<StartOutgoingCallUseCase>((
  ref,
) {
  return StartOutgoingCallUseCase(ref.read(callRepositoryProvider));
});

final endCallUseCaseProvider = Provider<EndCallUseCase>((ref) {
  return EndCallUseCase(ref.read(callRepositoryProvider));
});

final incomingCallProvider = StateProvider<CallInfo?>((ref) => null);

final currentCallSessionProvider = StateProvider<CallSession?>((ref) => null);

final lastRouteBeforeInCallProvider = StateProvider<String?>((ref) => null);
