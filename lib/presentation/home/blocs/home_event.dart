part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

final class InitialLoadHomeEvent extends HomeEvent {
  const InitialLoadHomeEvent();

  @override
  List<Object> get props => const [];
}

final class LoadHomeEvent extends HomeEvent {
  final int page;
  final int limit;

  const LoadHomeEvent({this.page = 1, this.limit = 20});

  @override
  List<Object> get props => [page, limit];
}

final class LoadMoreHomeEvent extends HomeEvent {
  const LoadMoreHomeEvent();

  @override
  List<Object> get props => const [];
}

final class _LocalConversationsChangedEvent extends HomeEvent {
  final List<Conversation> conversations;

  const _LocalConversationsChangedEvent(this.conversations);

  @override
  List<Object> get props => [conversations];
}

final class _LocalConversationsErrorEvent extends HomeEvent {
  final Failure failure;

  const _LocalConversationsErrorEvent(this.failure);

  @override
  List<Object> get props => [failure];
}

final class JoinConversationEvent extends HomeEvent {
  final String conversationId;

  const JoinConversationEvent(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}