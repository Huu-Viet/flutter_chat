part of 'registry_bloc.dart';

sealed class RegistryEvent extends Equatable {
  const RegistryEvent();

  @override
  List<Object?> get props => [];
}

final class RegistryInitEvent extends RegistryEvent {
  final String email;
  final String firstName;
  final String lastName;

  const RegistryInitEvent({
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [email, firstName, lastName];
}

final class RegistryCompleteEvent extends RegistryEvent {
  final String registrationToken;
  final String password;
  final String platform;
  final String? deviceName;

  const RegistryCompleteEvent({
    required this.registrationToken,
    required this.password,
    required this.platform,
    this.deviceName,
  });

  @override
  List<Object?> get props => [registrationToken, password, platform, deviceName];
}

final class RegistryVerifyOtpEvent extends RegistryEvent {
  final String email;
  final String otp;

  const RegistryVerifyOtpEvent({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}
