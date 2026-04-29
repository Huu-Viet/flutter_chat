import 'package:flutter_chat/features/call/export.dart';

abstract class CallRemoteDataSource {
  Future<CallDto> startCall(String conversationId, String callerId, String receiverId);
  Future<CallAcceptDto> acceptCall(String callId);
  Future<CallDto> declineCall(String callId);
  Future<CallDto> endCall(String callId);
  Future<CallDto> fetchSingleCallRecord(String callId);
  Future<CallTokenDto> getCallToken(String callId);
  Future<List<CallDto>> fetchCallRecords(String conversationId, int page, int limit);
  Future<void> joinSocketCall(String callId);
  Future<void> leaveSocketCall(String callId);
}