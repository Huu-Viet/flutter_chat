import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchConversationUseCase fetchConversationUseCase;

  HomeBloc({
    required this.fetchConversationUseCase,
  }) : super(HomeInitial()) {
    on<LoadHomeEvent>(_onLoadHome);
  }

  Future<void> _onLoadHome(LoadHomeEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    final result = await fetchConversationUseCase(event.page, event.limit);

    result.fold(
      (failure) => emit(HomeFailure(failure)),
      (conversations) => emit(HomeLoaded(conversations)),
    );
  }
}
