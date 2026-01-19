part of 'phone_auth_bloc.dart';

sealed class PhoneAuthState extends Equatable {
  const PhoneAuthState();

  @override
  List<Object?> get props => [];
}

final class PhoneAuthInitial extends PhoneAuthState {
  const PhoneAuthInitial();
}

class PhoneAuthLoading extends PhoneAuthState {
  const PhoneAuthLoading();
}

class OTPSent extends PhoneAuthState {
  final String verificationId;
  final String phoneNumber;

  const OTPSent(this.verificationId, this.phoneNumber);

  @override
  List<Object> get props => [verificationId, phoneNumber];
}

class PhoneAuthSuccess extends PhoneAuthState {
  final bool isNewUser;

  const PhoneAuthSuccess(this.isNewUser);

  @override
  List<Object> get props => [isNewUser];
}

class PhoneAuthError extends PhoneAuthState {
  final String message;
  final String? phoneNumber;
  final String? verificationId;

  const PhoneAuthError(
      this.message, {
        this.phoneNumber,
        this.verificationId,
      });

  @override
  List<Object?> get props => [message, phoneNumber, verificationId];
}

class OTPResent extends PhoneAuthState {
  final String verificationId;
  final String phoneNumber;

  const OTPResent(this.verificationId, this.phoneNumber);

  @override
  List<Object> get props => [verificationId, phoneNumber];
}

