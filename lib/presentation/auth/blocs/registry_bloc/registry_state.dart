part of 'registry_bloc.dart';

sealed class RegistryState extends Equatable {
  const RegistryState();

  @override
  List<Object?> get props => [];
}

final class RegistryInitial extends RegistryState {
  const RegistryInitial();

  @override
  List<Object> get props => [];
}

final class RegistryLoading extends RegistryState {
  const RegistryLoading();

  @override
  List<Object> get props => [];
}

final class RegistryInitSuccess extends RegistryState {
  const RegistryInitSuccess();

  @override
  List<Object> get props => [];
}

final class RegistryCompleteSuccess extends RegistryState {
  const RegistryCompleteSuccess();

  @override
  List<Object> get props => [];
}

final class RegistryVerifyOtpSuccess extends RegistryState {
  final String registrationToken;

  const RegistryVerifyOtpSuccess(this.registrationToken);

  @override
  List<Object> get props => [registrationToken];
}

final class RegistryError extends RegistryState {
  final String message;

  const RegistryError(this.message);

  @override
  List<Object> get props => [message];
}
