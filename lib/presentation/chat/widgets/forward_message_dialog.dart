import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
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

  List<Conversation> _allConversations = [];
  List<Conversation> _conversations = [];
  final Set<String> _selectedIds = {};
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isLoading = true;
  String _query = '';
  int _requestSeq = 0;

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
    Future.microtask(() => _loadAllConversations());
  }

  Future<void> _loadAllConversations() async {
    final homeState = ref.read(homeBlocProvider).state;
    if (homeState is HomeLoaded) {
      final localConversations = homeState.conversations
          .where((c) => c.id != widget.sourceConversationId)
          .toList(growable: false);
      if (mounted) {
        setState(() {
          _allConversations = localConversations;
          _conversations = localConversations;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final useCase = ref.read(searchConversationsUseCaseProvider);

      final data = await useCase(
        query: null,
        page: 1,
        limit: 100,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _allConversations = data.fold(
          (_) => [],
          (convos) => convos
              .where((c) => c.id != widget.sourceConversationId)
              .toList(),
        );
        _conversations = _allConversations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final normalizedQuery = value.trim();
    _applyLocalFilter(normalizedQuery);

    _searchDebounce?.cancel();
    if (normalizedQuery.isNotEmpty) {
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        _fetchConversations(query: normalizedQuery);
      });
    }
  }

  void _applyLocalFilter(String normalizedQuery) {
    if (!mounted) return;
    
    setState(() {
      _query = normalizedQuery;
      
      if (normalizedQuery.isEmpty) {
        _conversations = _allConversations;
      } else {
        // Immediately filter from all conversations
        _conversations = _allConversations
            .where((conversation) {
              final name = conversation.name.trim().toLowerCase();
              final q = normalizedQuery.toLowerCase();
              return name.contains(q);
            })
            .toList();
      }
    });
  }

  Future<void> _fetchConversations({String? query}) async {
    final reqId = ++_requestSeq;
    final normalizedQuery = query?.trim() ?? '';

    try {
      final useCase = ref.read(searchConversationsUseCaseProvider);

      final data = await useCase(
        query: normalizedQuery.isEmpty ? null : normalizedQuery,
        page: 1,
        limit: 30,
      );

      if (!mounted || reqId != _requestSeq) {
        return;
      }

      setState(() {
        final apiResults = data.fold(
          (_) => <Conversation>[],
          (convos) => convos
              .where((c) => c.id != widget.sourceConversationId)
              .toList(),
        );
        
        // Only update if API returned non-empty results
        if (apiResults.isNotEmpty) {
          _conversations = apiResults;
        }
        // If API returned empty, keep local filtered results
      });
    } catch (e) {
      if (!mounted || reqId != _requestSeq) {
        return;
      }
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

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
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

              //List of conversations
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _conversations.isEmpty
                    ? const Center(child: Text('No conversations found'))
                    : ListView.builder(
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          final convo = _conversations[index];
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

                            /// Checkbox
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleSelection(convo.id),
                            ),
                          );
                        },
                      ),
              ),

              const Divider(height: 1),

              /// ACTIONS
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

