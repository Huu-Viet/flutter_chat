class AuthTokenResponse {
  final String accessToken;
  final int expiresIn;
  final int refreshExpiresIn;
  final String refreshToken;
  final String tokenType;
  final int notBeforePolicy;
  final String sessionState;
  final String scope;

  AuthTokenResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.refreshToken,
    required this.tokenType,
    required this.notBeforePolicy,
    required this.sessionState,
    required this.scope,
  });

  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return AuthTokenResponse(
      accessToken: (payload['accessToken'] ?? payload['access_token'] ?? '').toString(),
      expiresIn: _toInt(payload['expiresIn'] ?? payload['expires_in']),
      refreshExpiresIn: _toInt(payload['refreshExpiresIn'] ?? payload['refresh_expires_in']),
      refreshToken: (payload['refreshToken'] ?? payload['refresh_token'] ?? '').toString(),
      tokenType: (payload['tokenType'] ?? payload['token_type'] ?? 'Bearer').toString(),
      notBeforePolicy: _toInt(payload['notBeforePolicy'] ?? payload['not-before-policy']),
      sessionState: (payload['sessionState'] ?? payload['session_state'] ?? '').toString(),
      scope: (payload['scope'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'expires_in': expiresIn,
      'refresh_expires_in': refreshExpiresIn,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'not-before-policy': notBeforePolicy,
      'session_state': sessionState,
      'scope': scope,
    };
  }

  @override
  String toString() => 'AuthTokenResponse('
      'accessToken: $accessToken, '
      'expiresIn: $expiresIn, '
      'refreshExpiresIn: $refreshExpiresIn, '
      'tokenType: $tokenType, '
      'scope: $scope)';
}