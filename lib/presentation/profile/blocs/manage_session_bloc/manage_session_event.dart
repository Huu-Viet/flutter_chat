part of 'manage_session_bloc.dart';

sealed class ManageSessionEvent extends Equatable {
  const ManageSessionEvent();

  @override
  List<Object?> get props => [];
}

final class LoadSessionsEvent extends ManageSessionEvent {
  const LoadSessionsEvent();
}

final class RefreshSessionsEvent extends ManageSessionEvent {
  const RefreshSessionsEvent();
}

final class RevokeOtherSessionsEvent extends ManageSessionEvent {
  const RevokeOtherSessionsEvent();
}

final class RevokeSessionEvent extends ManageSessionEvent {
  final String sessionId;

  const RevokeSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}
