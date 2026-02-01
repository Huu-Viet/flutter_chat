import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'network_service.dart';

class MobileDataWarningService {
  static const String _hasShownWarningKey = 'has_shown_mobile_data_warning';

  static Future<void> showMobileDataWarningIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownWarning = prefs.getBool(_hasShownWarningKey) ?? false;

    if (!hasShownWarning && context.mounted) {
      await _showMobileDataDialog(context);
      await prefs.setBool(_hasShownWarningKey, true);
    }
  }

  static Future<void> resetWarningPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasShownWarningKey);
  }

  static Future<void> _showMobileDataDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.signal_cellular_alt,
            color: Colors.orange,
            size: 48,
          ),
          title: const Text(
            'Cảnh báo dữ liệu di động',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bạn đang sử dụng dữ liệu di động. Việc sử dụng app có thể tiêu tốn dữ liệu của bạn.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Để có trải nghiệm tốt nhất, hãy kết nối WiFi.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Tiếp tục với 4G',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đã hiểu'),
            ),
          ],
        );
      },
    );
  }
}

// Widget listener đơn giản - không cần phức tạp
class MobileDataWarningListener extends ConsumerStatefulWidget {
  final Widget child;

  const MobileDataWarningListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MobileDataWarningListener> createState() =>
      _MobileDataWarningListenerState();
}

class _MobileDataWarningListenerState
    extends ConsumerState<MobileDataWarningListener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowMobileDataWarning();
    });
  }

  void _checkAndShowMobileDataWarning() {
    ref.listen<AsyncValue<NetworkStatus>>(
      networkStatusProvider,
      (previous, next) {
        next.whenData((networkStatus) {
          if (networkStatus.connectionType == NetworkConnectionType.mobile &&
              mounted) {
            MobileDataWarningService.showMobileDataWarningIfNeeded(context);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}