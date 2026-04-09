import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/auth/user_providers.dart';
import 'package:flutter_chat/features/auth/domain/entities/user.dart';
import 'package:flutter_chat/features/upload_media/upload_media_providers.dart';
import 'package:flutter_chat/presentation/profile/blocs/profile_bloc/profile_bloc.dart';
import 'package:flutter_chat/presentation/profile/blocs/set_profile_bloc/set_profile_bloc.dart';
import 'package:riverpod/riverpod.dart';

final setProfileBlocProvider = Provider.family.autoDispose<SetProfileBloc, MyUser>((ref, initialUser) {
  final bloc = SetProfileBloc(
    setUserInfoUseCase: ref.read(setUserInfoUseCaseProvider),
    uploadMediaUseCase: ref.read(uploadMediaUseCaseProvider),
    initialUser: initialUser,
  );

  ref.onDispose(bloc.close);
  return bloc;
});

final profileBlocProvider = Provider.autoDispose<ProfileBloc>((ref) {
  final bloc = ProfileBloc(
    ref.read(getCurrentUserIdUseCaseProvider),
    ref.read(getCurrentLocalUserInfoUseCaseProvider),
    ref.read(syncCurrentUserFromRemoteUseCaseProvider),
    ref.read(logoutUseCaseProvider),
  );

  ref.onDispose(bloc.close);
  return bloc;
});