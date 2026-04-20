import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class AudioCacheDao {
  Future<String?> getAudioPathByMediaId(String mediaId);
  Future<void> saveAudioPath({
    required String mediaId,
    required String localPath,
  });
  Future<void> deleteByMediaId(String mediaId);
}

class FileAudioCacheDaoImpl implements AudioCacheDao {
  static const String _audioFolderName = 'audio_cache';
  static const String _indexFileName = 'audio_cache_index.json';

  Future<File> _getIndexFile() async {
    final rootDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(rootDir.path, _audioFolderName));
    if (!audioDir.existsSync()) {
      await audioDir.create(recursive: true);
    }
    return File(p.join(audioDir.path, _indexFileName));
  }

  Future<Map<String, String>> _readIndex() async {
    final file = await _getIndexFile();
    if (!file.existsSync()) {
      return <String, String>{};
    }

    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return <String, String>{};
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, String>{};
      }

      final result = <String, String>{};
      decoded.forEach((key, value) {
        final id = key.toString().trim();
        final path = value.toString().trim();
        if (id.isNotEmpty && path.isNotEmpty) {
          result[id] = path;
        }
      });
      return result;
    } catch (_) {
      return <String, String>{};
    }
  }

  Future<void> _writeIndex(Map<String, String> index) async {
    final file = await _getIndexFile();
    await file.writeAsString(jsonEncode(index), flush: true);
  }

  @override
  Future<String?> getAudioPathByMediaId(String mediaId) async {
    final normalizedMediaId = mediaId.trim();
    if (normalizedMediaId.isEmpty) {
      return null;
    }

    final index = await _readIndex();
    final path = index[normalizedMediaId]?.trim();
    if (path == null || path.isEmpty) {
      return null;
    }

    return path;
  }

  @override
  Future<void> saveAudioPath({
    required String mediaId,
    required String localPath,
  }) async {
    final normalizedMediaId = mediaId.trim();
    final normalizedPath = localPath.trim();
    if (normalizedMediaId.isEmpty || normalizedPath.isEmpty) {
      return;
    }

    final index = await _readIndex();
    index[normalizedMediaId] = normalizedPath;
    await _writeIndex(index);
  }

  @override
  Future<void> deleteByMediaId(String mediaId) async {
    final normalizedMediaId = mediaId.trim();
    if (normalizedMediaId.isEmpty) {
      return;
    }

    final index = await _readIndex();
    if (!index.containsKey(normalizedMediaId)) {
      return;
    }

    index.remove(normalizedMediaId);
    await _writeIndex(index);
  }
}
