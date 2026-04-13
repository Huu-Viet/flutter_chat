part of 'contact_bloc.dart';

sealed class ContactState extends Equatable {
  const ContactState();
}

final class ContactInitial extends ContactState {
  @override
  List<Object> get props => [];
}
