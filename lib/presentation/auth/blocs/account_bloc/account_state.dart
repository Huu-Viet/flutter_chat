part of 'account_bloc.dart';

sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object> get props => [];
}

final class AccountInitial extends AccountState {}

final class AccountLoading extends AccountState {}

final class AccountSuccess extends AccountState {}

final class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object> get props => [message];
}

final class AccountForgotPasswordSuccess extends AccountState {}

final class AccountVerifyOtpSuccess extends AccountState {
  final String resetToken;

  const AccountVerifyOtpSuccess(this.resetToken);

  @override
  List<Object> get props => [resetToken];
}

final class AccountResetPasswordSuccess extends AccountState {}