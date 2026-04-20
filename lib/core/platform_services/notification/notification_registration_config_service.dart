import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_chat/core/constants/app_constants.dart';

class NotificationRegistrationConfig {
  final String apiKey;
  final String projectId;
  final String projectNumber;
  final String appId;
  final String packageName;

  const NotificationRegistrationConfig({
    required this.apiKey,
    required this.projectId,
    required this.projectNumber,
    required this.appId,
    required this.packageName,
  });
}

abstract class NotificationRegistrationConfigService {
  Future<NotificationRegistrationConfig> load();
}

class GoogleServicesNotificationRegistrationConfigService
    implements NotificationRegistrationConfigService {
  final String _assetPath;
  NotificationRegistrationConfig? _cached;

  GoogleServicesNotificationRegistrationConfigService({
    String assetPath = AppConstants.googleServicesAssetPath,
  }) : _assetPath = assetPath;

  @override
  Future<NotificationRegistrationConfig> load() async {
    final cached = _cached;
    if (cached != null) {
      return cached;
    }

    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid google-services.json format');
    }

    final projectInfo = decoded['project_info'];
    final clients = decoded['client'];
    if (projectInfo is! Map<String, dynamic> || clients is! List || clients.isEmpty) {
      throw const FormatException('Missing project_info or client in google-services.json');
    }

    final firstClient = clients.first;
    if (firstClient is! Map<String, dynamic>) {
      throw const FormatException('Invalid client entry in google-services.json');
    }

    final clientInfo = firstClient['client_info'];
    final androidClientInfo = clientInfo is Map<String, dynamic>
        ? clientInfo['android_client_info']
        : null;
    final apiKeys = firstClient['api_key'];
    final firstApiKey = apiKeys is List && apiKeys.isNotEmpty ? apiKeys.first : null;

    final apiKey = firstApiKey is Map<String, dynamic>
        ? (firstApiKey['current_key']?.toString() ?? '')
        : '';
    final projectId = projectInfo['project_id']?.toString() ?? '';
    final projectNumber = projectInfo['project_number']?.toString() ?? '';
    final appId = clientInfo is Map<String, dynamic>
        ? (clientInfo['mobilesdk_app_id']?.toString() ?? '')
        : '';
    final packageName = androidClientInfo is Map<String, dynamic>
        ? (androidClientInfo['package_name']?.toString() ?? '')
        : '';

    if (apiKey.isEmpty || projectId.isEmpty || appId.isEmpty) {
      throw const FormatException('Incomplete Firebase registration config');
    }

    final config = NotificationRegistrationConfig(
      apiKey: apiKey,
      projectId: projectId,
      projectNumber: projectNumber,
      appId: appId,
      packageName: packageName,
    );
    _cached = config;
    return config;
  }
}
