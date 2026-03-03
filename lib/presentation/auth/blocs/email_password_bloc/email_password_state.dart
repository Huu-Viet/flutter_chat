part of 'email_password_bloc.dart';

sealed class EmailPasswordState extends Equatable {
  const EmailPasswordState();

  @override
  List<Object> get props => [];
}

final class EmailPasswordInitial extends EmailPasswordState {}

final class EmailPasswordLoading extends EmailPasswordState {}

final class EmailPasswordSuccess extends EmailPasswordState {}

final class EmailPasswordError extends EmailPasswordState {
  final String message;

  const EmailPasswordError(this.message);

  @override
  List<Object> get props => [message];
}
