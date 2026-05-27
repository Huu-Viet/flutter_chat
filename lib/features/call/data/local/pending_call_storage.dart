import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class PendingCallStorage {
  Future<void> saveAcceptedCall(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getAcceptedCall();
  Future<void> clearAcceptedCall();
}

class PendingCallStorageImpl implements PendingCallStorage {
  static const _acceptedCallKey = 'accepted_call';

  @override
  Future<void> saveAcceptedCall(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _acceptedCallKey,
      jsonEncode(data),
    );
  }

  @override
  Future<Map<String, dynamic>?> getAcceptedCall() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_acceptedCallKey);
    if (raw == null || raw.isEmpty) return null;

    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  @override
  Future<void> clearAcceptedCall() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_acceptedCallKey);
  }
}