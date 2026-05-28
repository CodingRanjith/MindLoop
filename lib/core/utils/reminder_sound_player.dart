import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:mindloop/core/constants/reminder_ringtones.dart';

/// Plays built-in asset sounds or user-picked audio files.
class ReminderSoundPlayer {
  ReminderSoundPlayer._();

  static const String filePrefix = 'file://';

  static bool isCustomFile(String? source) {
    if (source == null || source.isEmpty) return false;
    if (source.startsWith(filePrefix)) return true;
    if (kIsWeb) return false;
    return source.contains(':\\') || source.startsWith('/');
  }

  static String toStoredFilePath(String path) {
    if (path.startsWith(filePrefix)) return path;
    return '$filePrefix$path';
  }

  static String filePathFromStored(String stored) {
    return stored.startsWith(filePrefix)
        ? stored.substring(filePrefix.length)
        : stored;
  }

  static String resolveAssetOrFile(String? musicAsset) {
    if (musicAsset == null || musicAsset.isEmpty) {
      return ReminderRingtones.assetForId(ReminderRingtones.defaultId);
    }
    return musicAsset;
  }

  static Future<bool> play(AudioPlayer player, String? musicAsset) async {
    final source = resolveAssetOrFile(musicAsset);
    await player.stop();
    try {
      if (isCustomFile(source)) {
        if (kIsWeb) return false;
        final path = filePathFromStored(source);
        await player.play(DeviceFileSource(path));
      } else {
        await player.play(AssetSource(source));
      }
      return true;
    } catch (_) {
      if (isCustomFile(source) || kIsWeb) return false;
      try {
        await player.play(AssetSource(ReminderRingtones.defaultAsset));
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  static Future<bool> tryPlay(AudioPlayer player, String? musicAsset) =>
      play(player, musicAsset);
}
