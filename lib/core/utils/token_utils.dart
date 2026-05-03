import 'dart:convert';

class TokenUtils {
  /// Returns token expiration time from JWT [exp] claim, or null if invalid.
  static DateTime? getTokenExpiry(String token) {
    try {
      final payload = _decodePayload(token);
      final exp = payload['exp'];

      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true)
            .toLocal();
      }

      if (exp is String) {
        final parsed = int.tryParse(exp);
        if (parsed != null) {
          return DateTime.fromMillisecondsSinceEpoch(parsed * 1000, isUtc: true)
              .toLocal();
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns true when token is still valid, false when expired/invalid.
  static bool isTokenValid(String? token) {
    if (token == null || token.trim().isEmpty) return false;
    final expiry = getTokenExpiry(token);
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  /// Returns true when refresh token is still valid.
  static bool isRefreshTokenValid(String? refreshToken) {
    return isTokenValid(refreshToken);
  }

  static String? getSessionId(String? token) {
    if (token == null || token.trim().isEmpty) {
      return null;
    }

    try {
      final payload = _decodePayload(token);
      final sid = payload['sid'];
      final sessionId = sid?.toString().trim();
      return sessionId == null || sessionId.isEmpty ? null : sessionId;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT format');
    }

    final normalized = base64Url.normalize(parts[1]);
    final payloadMap = jsonDecode(utf8.decode(base64Url.decode(normalized)));

    if (payloadMap is! Map<String, dynamic>) {
      throw const FormatException('Invalid JWT payload');
    }

    return payloadMap;
  }
}
