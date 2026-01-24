import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../native_services/mobile_data_warning_service.dart';
import 'network_banner.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: MobileDataWarningListener(
        child: NetworkBanner(
          child: child,
        ),
      ),
    );
  }
}