import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/chat/domain/usecases/get_conversation_usecase.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
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
  List<Conversation> _conversations = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = true;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
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
    Future.microtask(_fetchConversations);
  }

  Future<void> _fetchConversations() async {
    try {
      final useCase = ref.read(getConversationUseCaseProvider);

      final data = await useCase();

      setState(() {
        _conversations = data.fold(
              (_) => [],
              (convos) => convos
              .where((c) => c.id != widget.sourceConversationId)
              .toList(),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

              const Divider(height: 1),

              //List of conversations
              Expanded(
                child: ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final convo = _conversations[index];
                    final isSelected =
                    _selectedIds.contains(convo.id);

                    return ListTile(
                      onTap: () => _toggleSelection(convo.id),
                      leading: CircleAvatar(
                        child: CachedNetworkImage(imageUrl: convo.avatarUrl),
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

