import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/features/call/data/dtos/call_token_dto.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class CallRemoteDSImpl implements CallRemoteDataSource {
  final Dio dio;
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  CallRemoteDSImpl({
    required this.dio
  });

  @override
  Future<CallDto> startCall(String conversationId, String callerId, String receiverId) async {
    try {
      final body = {
        'conversationId': conversationId,
        'calleeIds': [callerId, receiverId],
      };
      final response = await dio.post('$_baseUrl/calls/start', data: body);
      if(response.statusCode != 201) throw Exception('${response.statusCode}');
      final data = response.data;
      return CallDto.fromJson(data);
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] startCall error: $e');
      rethrow;
    }
  }

  @override
  Future<CallAcceptDto> acceptCall(String callId) async {
    try {
      final body = {
        'callId': callId,
      };
      final response = await dio.post('$_baseUrl/calls/accept', data: body);
      if(response.statusCode != 200) throw Exception('${response.statusCode}');
      final data = response.data;
      return CallAcceptDto.fromJson(data);
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] acceptCall error: $e');
      rethrow;
    }
  }

  @override
  Future<CallDto> declineCall(String callId) async {
    try {
      final body = {
        'callId': callId,
      };
      final response = await dio.post('$_baseUrl/calls/decline', data: body);
      if(response.statusCode != 200) throw Exception('${response.statusCode}');
      final data = response.data;
      return CallDto.fromJson(data);
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] declineCall error: $e');
      rethrow;
    }
  }

  @override
  Future<CallDto> endCall(String callId) async {
    try {
      final body = {
        'callId': callId,
      };
      final response = await dio.post('$_baseUrl/calls/end', data: body);
      if(response.statusCode != 200) throw Exception('${response.statusCode}');
      final data = response.data;
      return CallDto.fromJson(data);
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] endCall error: $e');
      rethrow;
    }
  }

  @override
  Future<CallDto> fetchSingleCallRecord(String callId) async {
    try {
      final response = await dio.get('$_baseUrl/calls/$callId');
      if(response.statusCode != 200) throw Exception('${response.statusCode}');
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
      if(response.statusCode != 200) throw Exception('${response.statusCode}');
      final data = (response).data;
      return CallTokenDto.fromJson(data);
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] getCallToken error: $e');
      rethrow;
    }
  }

  @override
  Future<List<CallDto>> fetchCallRecords(String conversationId, int page, int limit) async {
    try {
      final body = {
        'page': page,
        'limit': limit,
      };
      final response = await dio.get('$_baseUrl/calls/history/$conversationId', queryParameters: body);
      if(response.statusCode != 200) throw Exception('${response.statusCode}');
      final data = (response).data as List<dynamic>;
      return data.map((e) => CallDto.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[CallRemoteDSImpl] fetchCallRecords error: $e');
      rethrow;
    }
  }
}
