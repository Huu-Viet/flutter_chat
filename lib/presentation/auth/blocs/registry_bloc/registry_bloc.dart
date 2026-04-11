import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'registry_event.dart';
part 'registry_state.dart';

class RegistryBloc extends Bloc<RegistryEvent, RegistryState> {
  final RegisterInitUseCase registerInitUseCase;
  final RegisterVerifyOtpUseCase registerVerifyOtpUseCase;
  final RegisterCompleteUseCase registerCompleteUseCase;

  RegistryBloc({
    required this.registerInitUseCase,
    required this.registerVerifyOtpUseCase,
    required this.registerCompleteUseCase,
  }) : super(RegistryInitial()) {
    on<RegistryInitEvent>(_onRegisterInit);
    on<RegistryVerifyOtpEvent>(_onRegisterVerifyOtp);
    on<RegistryCompleteEvent>(_onRegisterComplete);
  }

  Future<void> _onRegisterInit(
    RegistryInitEvent event,
    Emitter<RegistryState> emit,
  ) async {
    emit(RegistryLoading());

    final result = await registerInitUseCase(
      event.email,
      event.firstName,
      event.lastName,
    );

    result.fold(
      (failure) => emit(RegistryError(failure.message)),
      (_) => emit(RegistryInitSuccess()),
    );
  }

  Future<void> _onRegisterVerifyOtp(
    RegistryVerifyOtpEvent event,
    Emitter<RegistryState> emit,
  ) async {
    emit(RegistryLoading());

    final result = await registerVerifyOtpUseCase(event.email, event.otp);

    result.fold(
      (failure) => emit(RegistryError(failure.message)),
      (registrationToken) => emit(RegistryVerifyOtpSuccess(registrationToken)),
    );
  }

  Future<void> _onRegisterComplete(
    RegistryCompleteEvent event,
    Emitter<RegistryState> emit,
  ) async {
    emit(RegistryLoading());

    final result = await registerCompleteUseCase(
      event.registrationToken,
      event.password,
      event.platform,
      event.deviceName,
    );

    result.fold(
      (failure) => emit(RegistryError(failure.message)),
      (_) => emit(RegistryCompleteSuccess()),
    );
  }
}
