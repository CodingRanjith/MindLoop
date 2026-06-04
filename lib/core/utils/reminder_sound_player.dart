import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:mindloop/core/constants/reminder_ringtones.dart';
import 'package:mindloop/core/utils/reminder_audio_permissions.dart';

/// Plays built-in asset sounds or user-picked audio files.
class ReminderSoundPlayer {
  ReminderSoundPlayer._();

  static const String filePrefix = 'file://';
  static bool _configured = false;

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

  static Future<void> ensureConfigured() async {
    if (_configured || kIsWeb) return;

    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    _configured = true;
  }

  static Future<void> _configurePlayer(AudioPlayer player) async {
    await ensureConfigured();
    await player.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    await player.setVolume(1);
  }

  static Future<bool> play(AudioPlayer player, String? musicAsset) async {
    final source = resolveAssetOrFile(musicAsset);
    await player.stop();

    if (isCustomFile(source)) {
      if (kIsWeb) return false;
      final allowed = await ReminderAudioPermissions.ensureForCustomSound();
      if (!allowed) return false;

      final path = filePathFromStored(source);
      final file = File(path);
      if (!file.existsSync()) return false;

      try {
        await _configurePlayer(player);
        await player.play(DeviceFileSource(path));
        return true;
      } catch (_) {
        return false;
      }
    }

    final candidates = <String>[
      source,
      if (source.endsWith('.wav'))
        source.replaceFirst('.wav', '.ogg'),
      ReminderRingtones.defaultAsset,
      ReminderRingtones.defaultAsset.replaceFirst('.wav', '.ogg'),
    ];

    for (final asset in candidates) {
      try {
        await _configurePlayer(player);
        await player.play(AssetSource(asset));
        return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  static Future<bool> tryPlay(AudioPlayer player, String? musicAsset) =>
      play(player, musicAsset);
}
