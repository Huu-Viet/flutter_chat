part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

final class HomeInitial extends HomeState {
  @override
  List<Object?> get props => const [];
}

final class HomeLoading extends HomeState {
  @override
  List<Object?> get props => const [];
}

final class HomeLoaded extends HomeState {
  final List<Conversation> conversations;

  const HomeLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

final class HomeFailure extends HomeState {
  final Failure failure;

  const HomeFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}