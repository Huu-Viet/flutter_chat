import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final LogInWithGrantedAccountUseCase logInWithGrantedAccountUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyResetPassUseCase verifyOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AccountBloc({
    required this.logInWithGrantedAccountUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyOtpUseCase,
    required this.resetPasswordUseCase,
  }) : super(AccountInitial()) {
    on<LoginWithGrantedAccountEvent>(_loginWithGrantedAccount);
    on<ForgotPasswordEvent>(_onForgetPassword);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResetPasswordEvent>(_onResetPassword);
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

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event,
      Emitter<AccountState> emit,
      ) async {
    emit(AccountLoading());
    final result = await verifyOtpUseCase(event.email, event.otp);
    result.fold(
        (failure) => emit(AccountError(failure.message)),
        (resetToken) => emit(AccountVerifyOtpSuccess(resetToken))
    );
  }

  Future<void> _onForgetPassword(
      ForgotPasswordEvent event,
      Emitter<AccountState> emit,
      ) async {
    emit(AccountLoading());
    final result = await forgotPasswordUseCase(event.email);
    result.fold(
            (failure)=> emit(AccountError(failure.message)),
            (success) => emit(AccountForgotPasswordSuccess())
    );
  }

  Future<void> _onResetPassword(
      ResetPasswordEvent event,
      Emitter<AccountState> emit,
      ) async {
    emit(AccountLoading());
    final result = await resetPasswordUseCase(event.resetToken, event.newPassword);
    result.fold(
            (failure) => emit(AccountError(failure.message)),
            (success) => emit(AccountResetPasswordSuccess())
    );
  }
}


