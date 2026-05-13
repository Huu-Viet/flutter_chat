import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/chat/export.dart';

class ForwardConversationSearchState extends Equatable {
  final bool isLoading;
  final String query;
  final List<Conversation> allConversations;
  final List<Conversation> conversations;

  const ForwardConversationSearchState({
    this.isLoading = false,
    this.query = '',
    this.allConversations = const <Conversation>[],
    this.conversations = const <Conversation>[],
  });

  ForwardConversationSearchState copyWith({
    bool? isLoading,
    String? query,
    List<Conversation>? allConversations,
    List<Conversation>? conversations,
  }) {
    return ForwardConversationSearchState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      allConversations: allConversations ?? this.allConversations,
      conversations: conversations ?? this.conversations,
    );
  }

  @override
  List<Object> get props => [isLoading, query, allConversations, conversations];
}

class ForwardConversationSearchCubit extends Cubit<ForwardConversationSearchState> {
  final SearchConversationsUseCase searchConversationsUseCase;
  final String sourceConversationId;
  int _requestSeq = 0;

  ForwardConversationSearchCubit({
    required this.searchConversationsUseCase,
    required this.sourceConversationId,
  }) : super(const ForwardConversationSearchState(isLoading: true));

  Future<void> initialize({required List<Conversation> localConversations}) async {
    final filteredLocal = localConversations
        .where((c) => c.id != sourceConversationId)
        .toList(growable: false);

    if (filteredLocal.isNotEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          allConversations: filteredLocal,
          conversations: filteredLocal,
        ),
      );
      return;
    }

    await fetchInitialFromRemote();
  }

  Future<void> fetchInitialFromRemote() async {
    emit(state.copyWith(isLoading: true));

    final result = await searchConversationsUseCase(
      query: null,
      page: 1,
      limit: 100,
    );

    final conversations = result.fold(
      (_) => const <Conversation>[],
      (convos) => convos
          .where((c) => c.id != sourceConversationId)
          .toList(growable: false),
    );

    emit(
      state.copyWith(
        isLoading: false,
        allConversations: conversations,
        conversations: conversations,
      ),
    );
  }

  void applyLocalFilter(String query) {
    final normalizedQuery = query.trim();
    final q = normalizedQuery.toLowerCase();

    final filtered = normalizedQuery.isEmpty
        ? state.allConversations
        : state.allConversations.where((conversation) {
            final name = conversation.name.trim().toLowerCase();
            return name.contains(q);
          }).toList(growable: false);

    emit(state.copyWith(query: normalizedQuery, conversations: filtered));
  }

  Future<void> fetchRemote(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return;
    }

    final reqId = ++_requestSeq;
    final result = await searchConversationsUseCase(
      query: normalizedQuery,
      page: 1,
      limit: 30,
    );

    if (reqId != _requestSeq) {
      return;
    }

    final apiResults = result.fold(
      (_) => const <Conversation>[],
      (convos) => convos
          .where((c) => c.id != sourceConversationId)
          .toList(growable: false),
    );

    if (apiResults.isEmpty) {
      return;
    }

    emit(state.copyWith(conversations: apiResults));
  }
}
