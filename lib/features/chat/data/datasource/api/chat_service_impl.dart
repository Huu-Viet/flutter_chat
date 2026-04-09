import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatServiceImpl implements ChatService {
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  final Dio _dio;

  const ChatServiceImpl(this._dio);

  @override
  Future<ConversationResponse> fetchConversations(int page, int limit) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/conversations',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Failed to fetch conversations: ${response.statusCode}');
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      debugPrint('[ChatServiceImpl] Fetched conversations data: $responseBody');
      return ConversationResponse.fromJson(responseBody);
    } catch (e) {
      debugPrint('[ChatServiceImpl] Fetch conversations error: $e');
      throw Exception('Failed to fetch conversations: $e');
    }
  }

}