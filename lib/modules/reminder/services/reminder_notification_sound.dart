import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mindloop/modules/reminder/core/utils/reminder_sound_player.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies built-in or user-picked audio into app storage for Android notifications.
class ReminderNotificationSound {
  ReminderNotificationSound._();

  static const _allowedExt = {'.wav', '.mp3', '.ogg', '.m4a', '.aac'};

  static Future<Directory> _soundsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'notification_sounds'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<AndroidNotificationSound?> forReminder(
    String reminderId,
    String? musicAsset,
  ) async {
    if (!Platform.isAndroid) return null;

    try {
      await deleteForReminder(reminderId);
      final source = ReminderSoundPlayer.resolveAssetOrFile(musicAsset);
      final dir = await _soundsDir();

      if (ReminderSoundPlayer.isCustomFile(source)) {
        final path = ReminderSoundPlayer.filePathFromStored(source);
        final src = File(path);
        if (!await src.exists()) return null;
        final ext = _normalizeExt(p.extension(path));
        final dest = File(p.join(dir.path, '$reminderId$ext'));
        await src.copy(dest.path);
        return UriAndroidNotificationSound(dest.path);
      }

      final dest = File(p.join(dir.path, '$reminderId.wav'));
      if (!await _copyBundledAsset(source, dest)) return null;
      return UriAndroidNotificationSound(dest.path);
    } catch (e, st) {
      debugPrint('ReminderNotificationSound: $e\n$st');
      return null;
    }
  }

  static Future<bool> _copyBundledAsset(String assetPath, File dest) async {
    final candidates = <String>[
      assetPath,
      if (assetPath.endsWith('.wav')) assetPath.replaceFirst('.wav', '.ogg'),
      ReminderSoundPlayer.resolveAssetOrFile(null),
    ];
    for (final candidate in candidates) {
      try {
        final data = await rootBundle.load(candidate);
        await dest.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );
        return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  static String _normalizeExt(String ext) {
    final lower = ext.toLowerCase();
    if (_allowedExt.contains(lower)) return lower;
    return '.mp3';
  }

  static Future<void> deleteForReminder(String reminderId) async {
    if (!Platform.isAndroid) return;
    try {
      final dir = await _soundsDir();
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        if (p.basenameWithoutExtension(entity.path) == reminderId) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }
}
