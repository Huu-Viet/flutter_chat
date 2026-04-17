part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatLoaded extends ChatState {
  final List<Message> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

final class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
