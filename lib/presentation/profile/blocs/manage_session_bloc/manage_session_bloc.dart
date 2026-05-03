import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'manage_session_event.dart';
part 'manage_session_state.dart';

class ManageSessionBloc extends Bloc<ManageSessionEvent, ManageSessionState> {
  final GetActiveSessionsUseCase getActiveSessionsUseCase;
  final RevokeOtherSessionsUseCase revokeOtherSessionsUseCase;
  final RevokeSessionUseCase revokeSessionUseCase;
  final SignOutUseCase signOutUseCase;
  final ClearLocalAppDataUseCase clearLocalAppDataUseCase;

  ManageSessionBloc({
    required this.getActiveSessionsUseCase,
    required this.revokeOtherSessionsUseCase,
    required this.revokeSessionUseCase,
    required this.signOutUseCase,
    required this.clearLocalAppDataUseCase,
  }) : super(ManageSessionInitial()) {
    on<LoadSessionsEvent>(_onLoadSessions);
    on<RefreshSessionsEvent>(_onRefreshSessions);
    on<RevokeOtherSessionsEvent>(_onRevokeOtherSessions);
    on<RevokeSessionEvent>(_onRevokeSession);
  }

  Future<void> _onLoadSessions(
    LoadSessionsEvent event,
    Emitter<ManageSessionState> emit,
  ) async {
    emit(ManageSessionLoading());
    await _loadSessions(emit);
  }

  Future<void> _onRefreshSessions(
    RefreshSessionsEvent event,
    Emitter<ManageSessionState> emit,
  ) async {
    await _loadSessions(emit);
  }

  Future<void> _onRevokeOtherSessions(
    RevokeOtherSessionsEvent event,
    Emitter<ManageSessionState> emit,
  ) async {
    final currentSessions = state.sessions;
    emit(ManageSessionActionInProgress(currentSessions));

    final result = await revokeOtherSessionsUseCase();
    await result.fold(
      (failure) async => emit(ManageSessionError(failure.message, currentSessions)),
      (_) async {
        emit(ManageSessionActionSuccess('Other sessions have been revoked.'));
        await _loadSessions(emit);
      },
    );
  }

  Future<void> _onRevokeSession(
    RevokeSessionEvent event,
    Emitter<ManageSessionState> emit,
  ) async {
    final currentSessions = state.sessions;
    emit(ManageSessionActionInProgress(currentSessions));
    final isCurrentSession = currentSessions.any(
      (session) => session.id == event.sessionId && session.isCurrent,
    );

    final result = await revokeSessionUseCase(event.sessionId);
    await result.fold(
      (failure) async => emit(ManageSessionError(failure.message, currentSessions)),
      (_) async {
        if (isCurrentSession) {
          await signOutUseCase();
          await clearLocalAppDataUseCase();
          emit(ManageSessionCurrentSessionRevoked());
          return;
        }

        emit(ManageSessionActionSuccess('Session has been revoked.'));
        await _loadSessions(emit);
      },
    );
  }

  Future<void> _loadSessions(Emitter<ManageSessionState> emit) async {
    final result = await getActiveSessionsUseCase();
    result.fold(
      (failure) => emit(ManageSessionError(failure.message, state.sessions)),
      (sessions) => emit(ManageSessionLoaded(sessions)),
    );
  }
}
