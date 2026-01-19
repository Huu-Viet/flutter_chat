import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network_banner.dart';
import '../services/mobile_data_warning_service.dart';

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