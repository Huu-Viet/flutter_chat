import 'package:flutter_chat/application/notification/notification_device_repository.dart';

class GetNotificationDeviceIdUseCase {
  final NotificationDeviceRepository _repository;

  const GetNotificationDeviceIdUseCase(this._repository);

  Future<String> call() => _repository.getOrCreateDeviceId();
}
