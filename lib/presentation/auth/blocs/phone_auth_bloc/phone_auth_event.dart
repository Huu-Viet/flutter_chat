part of 'phone_auth_bloc.dart';

sealed class PhoneAuthEvent extends Equatable {
  const PhoneAuthEvent();
}

class SendOTPEvent extends PhoneAuthEvent{
  final String phoneNumber;

  const SendOTPEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOTPEvent extends PhoneAuthEvent {
  final String verificationId;
  final String otpCode;

  const VerifyOTPEvent(this.verificationId, this.otpCode);

  @override
  List<Object> get props => [verificationId, otpCode];
}

class ResendOTPEvent extends PhoneAuthEvent {
  final String phoneNumber;

  const ResendOTPEvent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class ResetPhoneAuthEvent extends PhoneAuthEvent {
  const ResetPhoneAuthEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}