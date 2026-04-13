import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Increment this signal to force app-wide navigation back to login.
final forceLogoutTickProvider = StateProvider<int>((ref) => 0);
