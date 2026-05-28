import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:mindloop/core/utils/reminder_sound_player.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class CustomAudioTrack {
  const CustomAudioTrack({required this.path, required this.label});

  final String path;
  final String label;

  String get storedValue => ReminderSoundPlayer.toStoredFilePath(path);
}

class CustomRingtoneService {
  CustomRingtoneService(this._prefs);

  static const _folderKey = 'custom_music_folder_path';

  static const _audioExtensions = {
    '.mp3',
    '.wav',
    '.ogg',
    '.m4a',
    '.aac',
    '.flac',
    '.webm',
  };

  static final _audioTypeGroup = XTypeGroup(
    label: 'Audio',
    extensions: _audioExtensions.map((e) => e.substring(1)).toList(),
  );

  final SharedPreferences _prefs;

  String? get savedFolderPath => _prefs.getString(_folderKey);

  Future<String?> pickMusicFolder() async {
    if (kIsWeb) return null;

    final path = await getDirectoryPath();
    if (path == null || path.isEmpty) return null;
    await _prefs.setString(_folderKey, path);
    return path;
  }

  Future<String?> pickSingleAudioFile() async {
    final file = await openFile(acceptedTypeGroups: [_audioTypeGroup]);
    return file?.path;
  }

  List<CustomAudioTrack> listTracksInFolder(String folderPath) {
    if (kIsWeb) return [];
    try {
      final dir = Directory(folderPath);
      if (!dir.existsSync()) return [];

      final files = dir
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((f) => _isAudioFile(f.path))
          .toList()
        ..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

      return files
          .map(
            (f) => CustomAudioTrack(
              path: f.path,
              label: p.basenameWithoutExtension(f.path),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<CustomAudioTrack> tracksFromSavedFolder() {
    final folder = savedFolderPath;
    if (folder == null || folder.isEmpty) return [];
    return listTracksInFolder(folder);
  }

  bool _isAudioFile(String path) {
    final ext = p.extension(path).toLowerCase();
    return _audioExtensions.contains(ext);
  }
}
