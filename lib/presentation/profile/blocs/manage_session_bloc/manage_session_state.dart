part of 'manage_session_bloc.dart';

sealed class ManageSessionState extends Equatable {
  const ManageSessionState();

  List<UserSession> get sessions => const [];

  @override
  List<Object?> get props => [];
}

final class ManageSessionInitial extends ManageSessionState {}

final class ManageSessionLoading extends ManageSessionState {}

final class ManageSessionLoaded extends ManageSessionState {
  @override
  final List<UserSession> sessions;

  const ManageSessionLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

final class ManageSessionActionInProgress extends ManageSessionState {
  @override
  final List<UserSession> sessions;

  const ManageSessionActionInProgress(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

final class ManageSessionActionSuccess extends ManageSessionState {
  final String message;

  const ManageSessionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class ManageSessionCurrentSessionRevoked extends ManageSessionState {}

final class ManageSessionError extends ManageSessionState {
  final String message;
  @override
  final List<UserSession> sessions;

  const ManageSessionError(this.message, [this.sessions = const []]);

  @override
  List<Object?> get props => [message, sessions];
}
