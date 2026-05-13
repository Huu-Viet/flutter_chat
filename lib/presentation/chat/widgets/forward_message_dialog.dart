import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/chat/blocs/forward_conversation_search_cubit.dart';
import 'package:flutter_chat/presentation/home/blocs/home_bloc.dart';
import 'package:flutter_chat/presentation/home/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForwardMessageDialog extends ConsumerStatefulWidget {
  final String messageId;
  final String sourceConversationId;
  final void Function(List<String> conversationIds) onSend;

  const ForwardMessageDialog({
    super.key,
    required this.messageId,
    required this.sourceConversationId,
    required this.onSend,
  });

  @override
  ConsumerState<ForwardMessageDialog> createState() => _ForwardMessageDialogState();
}

class _ForwardMessageDialogState extends ConsumerState<ForwardMessageDialog>{
  static const int _maxTargets = 10;

  late final ForwardConversationSearchCubit _searchCubit;
  final Set<String> _selectedIds = {};
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        if (_selectedIds.length >= _maxTargets) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select up to 10 conversations'),
            ),
          );
          return;
        }
        _selectedIds.add(id);
      }
    });
  }

  void _handleSend() {
    widget.onSend(_selectedIds.toList());
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _searchCubit = ForwardConversationSearchCubit(
      searchConversationsUseCase: ref.read(searchConversationsUseCaseProvider),
      sourceConversationId: widget.sourceConversationId,
    );

    final homeState = ref.read(homeBlocProvider).state;
    final localConversations = homeState is HomeLoaded
        ? homeState.conversations
        : const <Conversation>[];
    Future.microtask(
      () => _searchCubit.initialize(localConversations: localConversations),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchCubit.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final normalizedQuery = value.trim();
    _searchCubit.applyLocalFilter(normalizedQuery);

    _searchDebounce?.cancel();
    if (normalizedQuery.isNotEmpty) {
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        _searchCubit.fetchRemote(normalizedQuery);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      child: SafeArea(
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  l10n.action_forward,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              BlocBuilder<ForwardConversationSearchCubit, ForwardConversationSearchState>(
                bloc: _searchCubit,
                builder: (context, searchState) {
                  final conversations = searchState.conversations;
                  final isLoading = searchState.isLoading;
                  final query = searchState.query;

                  return Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: l10n.search,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: query.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : conversations.isEmpty
                                  ? const Center(
                                      child: Text('No conversations found'),
                                    )
                                  : ListView.builder(
                                      itemCount: conversations.length,
                                      itemBuilder: (context, index) {
                                        final convo = conversations[index];
                                        final isSelected = _selectedIds.contains(convo.id);

                                        return ListTile(
                                          onTap: () => _toggleSelection(convo.id),
                                          leading: CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            child: convo.avatarUrl.trim().isEmpty
                                                ? const Icon(Icons.groups_rounded)
                                                : ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl: convo.avatarUrl,
                                                      width: 40,
                                                      height: 40,
                                                      fit: BoxFit.cover,
                                                      errorWidget: (_, __, ___) =>
                                                          const Icon(Icons.groups_rounded),
                                                    ),
                                                  ),
                                          ),
                                          title: Text(convo.name),
                                          trailing: Checkbox(
                                            value: isSelected,
                                            onChanged: (_) => _toggleSelection(convo.id),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.close),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                        _selectedIds.isEmpty ? null : _handleSend,
                        child: Text("${l10n.send} (${_selectedIds.length})"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

