import 'package:firebase_auth/firebase_auth.dart';

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

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['access_token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      refreshExpiresIn: json['refresh_expires_in'] ?? 0,
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      notBeforePolicy: json['not-before-policy'] ?? 0,
      sessionState: json['session_state'] ?? '',
      scope: json['scope'] ?? '',
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