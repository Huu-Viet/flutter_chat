import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/auth/user_providers.dart';
import 'package:flutter_chat/presentation/profile/blocs/profile_bloc/profile_bloc.dart';
import 'package:flutter_chat/presentation/profile/blocs/set_profile_bloc/set_profile_bloc.dart';
import 'package:riverpod/riverpod.dart';

final setProfileBlocProvider = Provider<SetProfileBloc>((ref) {
  return SetProfileBloc(
    ref.read(setUserInfoUseCaseProvider),
    ref.read(getCurrentUserUseCaseProvider),
  );
});

final profileBlocProvider = Provider<ProfileBloc>((ref) {
  return ProfileBloc(
    ref.read(getCurrentUserIdUseCaseProvider),
    ref.read(getCurrentLocalUserInfoUseCaseProvider),
    ref.read(syncCurrentUserFromRemoteUseCaseProvider),
  );
});