part of 'in_call_bloc.dart';

sealed class InCallEvent extends Equatable {
  const InCallEvent();

  @override
  List<Object?> get props => [];
}

final class InCallSessionChanged extends InCallEvent {
  final CallSession? session;

  const InCallSessionChanged(this.session);

  @override
  List<Object?> get props => [session];
}

final class InCallEndRequested extends InCallEvent {
  const InCallEndRequested();
}

final class InCallErrorCleared extends InCallEvent {
  const InCallErrorCleared();
}

final class InCallEndStatusConsumed extends InCallEvent {
  const InCallEndStatusConsumed();
}
