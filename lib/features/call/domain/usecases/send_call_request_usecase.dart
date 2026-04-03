import 'package:flutter_chat/features/call/domain/repositories/call_repository.dart';

class SendCallRequestUseCase {
  final CallRepository _callRepository;

  SendCallRequestUseCase(this._callRepository);

  Future<void> call(String deviceToken, String message, String channelId) async {
    final result = await _callRepository.sendCallNotification(deviceToken, message, channelId);
    result.fold(
      (failure) => throw Exception(failure.toString()),
      (_) => null,
    );
  }
}