part of 'email_password_bloc.dart';

sealed class EmailPasswordEvent extends Equatable {
  const EmailPasswordEvent();
}

final class SignInWithEmailPasswordEvent extends EmailPasswordEvent {
  final String email;
  final String password;

  const SignInWithEmailPasswordEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

