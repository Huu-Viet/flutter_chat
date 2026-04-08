part of 'account_bloc.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();
}

final class LoginWithGrantedAccountEvent extends AccountEvent {
  final String username;
  final String password;

  const LoginWithGrantedAccountEvent(this.username, this.password);

  @override
  List<Object> get props => [username, password];
}


class ForgotPasswordEvent extends AccountEvent {
  final String email;

  const ForgotPasswordEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyOtpEvent extends AccountEvent {
  final String email;
  final String otp;

  const VerifyOtpEvent({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

class ResetPasswordEvent extends AccountEvent {
  final String resetToken;
  final String newPassword;

  const ResetPasswordEvent({
    required this.resetToken,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [resetToken, newPassword];
}