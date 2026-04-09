import 'dart:io';

import 'package:crypto/crypto.dart';

class ChecksumUtils {
  static const String sha256Algorithm = 'sha256';

  /// Builds checksum in format: "sha256:<hex_digest>".
  static Future<String> buildSha256ChecksumFromFile(
    String filePath,
  ) async {
    final bytes = await File(filePath).readAsBytes();
    final digest = sha256.convert(bytes).toString();
    return '$sha256Algorithm:$digest';
  }

  /// Returns only the hex digest (without "sha256:" prefix).
  static Future<String> buildSha256DigestFromFile(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return sha256.convert(bytes).toString();
  }
}
