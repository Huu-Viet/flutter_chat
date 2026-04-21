import 'package:flutter_chat/core/platform_services/fcm/fcm_service.dart';

class SyncDeviceTokenUseCase {
  final FCMService _fcmService;

  SyncDeviceTokenUseCase(this._fcmService);

  Future<void> call() => _fcmService.syncToken();
}
