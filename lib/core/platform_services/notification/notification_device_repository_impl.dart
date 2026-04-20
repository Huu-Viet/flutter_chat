import 'package:flutter_chat/application/notification/notification_device_repository.dart';
import 'package:flutter_chat/core/platform_services/notification/notification_device_id_service.dart';

class NotificationDeviceRepositoryImpl implements NotificationDeviceRepository {
  final NotificationDeviceIdService _deviceIdService;

  const NotificationDeviceRepositoryImpl(this._deviceIdService);

  @override
  Future<String> getOrCreateDeviceId() {
    return _deviceIdService.getOrCreateDeviceId();
  }
}
