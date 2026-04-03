import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final LogInWithGrantedAccountUseCase logInWithGrantedAccountUseCase;
  AccountBloc({
    required this.logInWithGrantedAccountUseCase
  }) : super(AccountInitial()) {
    on<LoginWithGrantedAccountEvent>(_loginWithGrantedAccount);
  }

  Future<void> _loginWithGrantedAccount(
      LoginWithGrantedAccountEvent event,
      Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());

    try {
      final result = await logInWithGrantedAccountUseCase(event.username, event.password);
      result.fold(
              (failure) => emit(AccountError(failure.message)),
              (authResult) => emit(AccountSuccess())
      );
    } catch (e) {
      emit(AccountError('Có lỗi xảy ra: $e'));
    }
  }
}


