part of 'set_profile_bloc.dart';

class SetProfileState extends Equatable {
  final MyUser initialUser;
  final String firstName;
  final String lastName;
  final String userName;
  final String? avatarMediaId;
  final String? avatarLocalPath;
  final bool isAvatarUploading;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const SetProfileState({
    required this.initialUser,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.avatarMediaId,
    required this.avatarLocalPath,
    required this.isAvatarUploading,
    required this.isSubmitting,
    required this.isSuccess,
    required this.errorMessage,
  });

  factory SetProfileState.initial(MyUser initialUser) {
    return SetProfileState(
      initialUser: initialUser,
      firstName: initialUser.firstName ?? '',
      lastName: initialUser.lastName ?? '',
      userName: initialUser.username,
      avatarMediaId: initialUser.avatarMediaId,
      avatarLocalPath: null,
      isAvatarUploading: false,
      isSubmitting: false,
      isSuccess: false,
      errorMessage: null,
    );
  }

  bool get hasTextChanges {
    final initialFirst = (initialUser.firstName ?? '').trim();
    final initialLast = (initialUser.lastName ?? '').trim();
    final initialUserName = initialUser.username.trim();

    return firstName.trim() != initialFirst ||
        lastName.trim() != initialLast ||
        userName.trim() != initialUserName;
  }

  bool get hasAvatarChanges {
    final initialAvatarMediaId = initialUser.avatarMediaId;
    return avatarMediaId != initialAvatarMediaId;
  }

  bool get hasAnyChanges {
    return hasTextChanges || hasAvatarChanges;
  }

  bool get isFormValid {
    return firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        userName.trim().isNotEmpty;
  }

  bool get canSubmit {
    final avatarReady = !hasAvatarChanges ||
        (avatarMediaId != null && avatarMediaId!.trim().isNotEmpty);

    return !isAvatarUploading &&
        !isSubmitting &&
        hasAnyChanges &&
        avatarReady;
  }

  SetProfileState copyWith({
    String? firstName,
    String? lastName,
    String? userName,
    String? avatarMediaId,
    bool clearAvatarMediaId = false,
    String? avatarLocalPath,
    bool clearAvatarLocalPath = false,
    bool? isAvatarUploading,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SetProfileState(
      initialUser: initialUser,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userName: userName ?? this.userName,
      avatarMediaId: clearAvatarMediaId
          ? null
          : (avatarMediaId ?? this.avatarMediaId),
      avatarLocalPath: clearAvatarLocalPath
          ? null
          : (avatarLocalPath ?? this.avatarLocalPath),
      isAvatarUploading: isAvatarUploading ?? this.isAvatarUploading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        initialUser,
        firstName,
        lastName,
        userName,
        avatarMediaId,
        avatarLocalPath,
        isAvatarUploading,
        isSubmitting,
        isSuccess,
        errorMessage,
      ];
}

