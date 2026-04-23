import 'package:flutter_chat/features/chat/export.dart';

class EmitTypingUseCase {
  final ChatRepository _repo;

  EmitTypingUseCase(this._repo);

  Future<void> call(String conversationId, bool isTyping) async {
    await _repo.sendTypingIndicator(conversationId, isTyping);
  }
}