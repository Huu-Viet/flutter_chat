import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CallRemoteDSImpl implements CallRemoteDataSource {
  final Dio dio;
  final RealtimeGateway realtimeGateway;
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  CallRemoteDSImpl({required this.dio, required this.realtimeGateway});

  @override
  Future<CallDto> startCall(
    String conversationId,
    String callerId,
    List<String> calleeIds,
  ) async {
    final normalizedConversationId = conversationId.trim();
    final normalizedCallerId = callerId.trim();
    final normalizedCalleeIds = calleeIds
        .map((calleeId) => calleeId.trim())
        .where((calleeId) => calleeId.isNotEmpty)
        .toSet()
        .toList();
    final url = '$_baseUrl/calls/start';

    try {
      if (normalizedConversationId.isEmpty) {
        throw Exception('Conversation ID is empty');
      }
      if (normalizedCallerId.isEmpty) {
        throw Exception('Caller ID is empty');
      }
      if (normalizedCalleeIds.isEmpty) {
        throw Exception('Callee IDs is empty');
      }

      final body = {
        'conversationId': normalizedConversationId,
        'calleeIds': normalizedCalleeIds,
      };
      debugPrint(
        '[CallRemoteDSImpl] startCall request -> url=$url, body=$body',
      );
      final response = await dio.post(url, data: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('${response.statusCode}');
      }
      return CallDto.fromJson(_toMap(response.data));
    } on DioException catch (e) {
      debugPrint(
        '[CallRemoteDSImpl] startCall dio error -> url=$url, conversationId=$normalizedConversationId, '
        'calleeIds=$normalizedCalleeIds, status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] startCall error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw Exception('Unsupported call response type: ${value.runtimeType}');
  }

  @override
  Future<CallAcceptDto> acceptCall(String callId) async {
    final normalizedCallId = callId.trim();
    final url = '$_baseUrl/calls/$normalizedCallId/accept';

    try {
      if (normalizedCallId.isEmpty) {
        throw Exception('Call ID is empty');
      }

      debugPrint(
        '[CallRemoteDSImpl] acceptCall request -> url=$url, callId=$normalizedCallId',
      );
      final response = await dio.post(url);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('${response.statusCode}');
      }
      final data = response.data;
      debugPrint('[CallRemoteDSImpl] acceptCall success -> data=$data');
      return CallAcceptDto.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '[CallRemoteDSImpl] acceptCall dio error -> url=$url, callId=$normalizedCallId, '
        'status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] acceptCall error: $e');
      rethrow;
    }
  }

  @override
  Future<CallDto> declineCall(String callId) async {
    final normalizedCallId = callId.trim();
    final url = '$_baseUrl/calls/$normalizedCallId/decline';

    try {
      if (normalizedCallId.isEmpty) {
        throw Exception('Call ID is empty');
      }

      debugPrint(
        '[CallRemoteDSImpl] declineCall request -> url=$url, callId=$normalizedCallId',
      );
      final response = await dio.post(url);
      if (response.statusCode != 200) throw Exception('${response.statusCode}');
      final data = response.data;
      return CallDto.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '[CallRemoteDSImpl] declineCall dio error -> url=$url, callId=$normalizedCallId, '
        'status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] declineCall error: $e');
      rethrow;
    }
  }

  @override
  Future<CallDto> endCall(String callId) async {
    final normalizedCallId = callId.trim();
    final url = '$_baseUrl/calls/$normalizedCallId/end';

    try {
      if (normalizedCallId.isEmpty) {
        throw Exception('Call ID is empty');
      }

      debugPrint(
        '[CallRemoteDSImpl] endCall request -> url=$url, callId=$normalizedCallId',
      );
      final response = await dio.post(url);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('${response.statusCode}');
      }
      final data = response.data;
      return CallDto.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '[CallRemoteDSImpl] endCall dio error -> url=$url, callId=$normalizedCallId, '
        'status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] endCall error: $e');
      rethrow;
    }
  }

  @override
  Future<CallDto> fetchSingleCallRecord(String callId) async {
    try {
      final response = await dio.get('$_baseUrl/calls/$callId');
      if (response.statusCode != 200) throw Exception('${response.statusCode}');
      final data = (response).data;
      return CallDto.fromJson(data);
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] fetchSingleCallRecord error: $e');
      rethrow;
    }
  }

  @override
  Future<CallTokenDto> getCallToken(String callId) async {
    try {
      final response = await dio.get('$_baseUrl/calls/$callId/token');
      if (response.statusCode != 200) throw Exception('${response.statusCode}');
      final data = (response).data;
      return CallTokenDto.fromJson(data);
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] getCallToken error: $e');
      rethrow;
    }
  }

  @override
  Future<List<CallDto>> fetchCallRecords(
    String conversationId,
    int page,
    int limit,
  ) async {
    try {
      final body = {'page': page, 'limit': limit};
      final response = await dio.get(
        '$_baseUrl/calls/history/$conversationId',
        queryParameters: body,
      );
      if (response.statusCode != 200) throw Exception('${response.statusCode}');
      final responseData = response.data;
      final data = responseData is Map
          ? (responseData['data'] as List<dynamic>? ?? const <dynamic>[])
          : (responseData as List<dynamic>);
      return data
          .map((e) => CallDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] fetchCallRecords error: $e');
      rethrow;
    }
  }

  @override
  Future<void> joinSocketCall(String callId) async {
    try {
      await realtimeGateway.emitCallEvent('call:join_room', {'callId': callId});
    } catch (e) {
      debugPrint('[CallServiceImpl] Join room error: $e');
      throw Exception('$e');
    }
  }

  @override
  Future<void> leaveSocketCall(String callId) async {
    try {
      await realtimeGateway.emitCallEvent('call:leave_room', {
        'callId': callId,
      });
    } catch (e) {
      debugPrint('[CallServiceImpl] Leave room error: $e');
      throw Exception('$e');
    }
  }
}
