  import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'email_password_event.dart';
part 'email_password_state.dart';

class EmailPasswordBloc extends Bloc<EmailPasswordEvent, EmailPasswordState> {
  final SignInWithEmailAndPasswordUseCase signInWithEmailPassword;
  EmailPasswordBloc({
    required this.signInWithEmailPassword,
  }) : super(EmailPasswordInitial()) {
    on<SignInWithEmailPasswordEvent>(_signInWithEmailAndPassword);
  }

  Future<void> _signInWithEmailAndPassword(
      SignInWithEmailPasswordEvent event,
      Emitter<EmailPasswordState> emit,
  ) async {
    emit(EmailPasswordLoading());

    try {
      final result = await signInWithEmailPassword(event.email, event.password);
      result.fold(
          (failure) => emit(EmailPasswordError(failure.message)),
          (authResult) => emit(EmailPasswordSuccess())
      );
    } catch (e) {
      emit(EmailPasswordError('Có lỗi xảy ra: $e'));
    }
  }
}

