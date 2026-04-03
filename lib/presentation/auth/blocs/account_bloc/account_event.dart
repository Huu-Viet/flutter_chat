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
