import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'phone_auth_event.dart';
part 'phone_auth_state.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  final SendPhoneOTPUseCase sendPhoneOTP;
  final VerifyPhoneOTPUseCase verifyPhoneOTP;

  PhoneAuthBloc({
    required this.sendPhoneOTP,
    required this.verifyPhoneOTP
  }) : super(PhoneAuthInitial()) {
    on<SendOTPEvent>(_sendOTP);
    on<VerifyOTPEvent>(_onVerifyOTP);
    on<ResendOTPEvent>(_onResendOTP);
    on<ResetPhoneAuthEvent>(_onReset);
  }

  void _sendOTP(SendOTPEvent event, Emitter<PhoneAuthState> emit) async {
    log('_sendOTP called with phone: ${event.phoneNumber}');
    emit(const PhoneAuthLoading());
    
    try {
      final result = await sendPhoneOTP(event.phoneNumber);
      result.fold(
          (failure) {
            log('SendOTP failed: ${failure.message}');
            emit(PhoneAuthError(failure.message, phoneNumber: event.phoneNumber));
          },
          (verificationId) {
            log('SendOTP success, verificationId: $verificationId');
            emit(OTPSent(verificationId, event.phoneNumber));
          }
      );
    } catch (e) {
      log('SendOTP exception: $e');
      emit(PhoneAuthError('Có lỗi xảy ra: $e', phoneNumber: event.phoneNumber));
    }
  }

  void _onVerifyOTP(VerifyOTPEvent event, Emitter<PhoneAuthState> emit) async {
    emit(PhoneAuthLoading());

    final result = await verifyPhoneOTP(event.verificationId, event.otpCode);
    result.fold(
        (failure) => emit(PhoneAuthError(
            failure.message,
            verificationId: event.verificationId
        )),
        (authResult) {
          emit(PhoneAuthSuccess(authResult.isNewUser));
        }
    );
  }

  void _onResendOTP(ResendOTPEvent event, Emitter<PhoneAuthState> emit) async {
    emit(const PhoneAuthLoading());

    final result = await sendPhoneOTP(event.phoneNumber);

    result.fold(
          (failure) => emit(PhoneAuthError(
        failure.message,
        phoneNumber: event.phoneNumber,
      )),
          (verificationId) => emit(OTPResent(verificationId, event.phoneNumber)),
    );
  }

  void _onReset(ResetPhoneAuthEvent event, Emitter<PhoneAuthState> emit) {
    emit(const PhoneAuthInitial());
  }
}