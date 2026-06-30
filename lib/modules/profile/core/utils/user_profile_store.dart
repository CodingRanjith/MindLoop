import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mindloop/core/constants/app_constants.dart';
import 'package:mindloop/modules/profile/domain/entities/user_profile.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only user profile (SharedPreferences + app documents for avatar).
class UserProfileStore {
  UserProfileStore(this._prefs);

  final SharedPreferences _prefs;

  static const nameKey = 'profile_name';
  static const dobKey = 'profile_dob';
  static const genderKey = 'profile_gender';
  static const imagePathKey = 'profile_image_path';

  static const genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  UserProfile load() {
    final dobRaw = _prefs.getString(dobKey);
    DateTime? dob;
    if (dobRaw != null && dobRaw.isNotEmpty) {
      dob = DateTime.tryParse(dobRaw);
    }
    return UserProfile(
      name: _prefs.getString(nameKey) ?? '',
      dateOfBirth: dob,
      gender: _prefs.getString(genderKey) ?? '',
      profileImagePath: _prefs.getString(imagePathKey),
    );
  }

  Future<void> save(UserProfile profile) async {
    await _prefs.setString(nameKey, profile.name.trim());
    if (profile.dateOfBirth != null) {
      final d = profile.dateOfBirth!;
      await _prefs.setString(
        dobKey,
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      );
    } else {
      await _prefs.remove(dobKey);
    }
    await _prefs.setString(genderKey, profile.gender);
    if (profile.profileImagePath != null && profile.profileImagePath!.isNotEmpty) {
      await _prefs.setString(imagePathKey, profile.profileImagePath!);
    } else {
      await _prefs.remove(imagePathKey);
    }
    if (profile.name.trim().isNotEmpty) {
      await _prefs.setString(AppConstants.prefsUserName, profile.name.trim());
    }
  }

  Future<String?> persistProfileImage(String sourcePath) async {
    if (sourcePath.isEmpty) return null;
    if (kIsWeb) return sourcePath;
    try {
      final source = File(sourcePath);
      if (!await source.exists()) return null;
      final dir = await getApplicationDocumentsDirectory();
      final destPath = p.join(dir.path, 'profile_avatar.jpg');
      await source.copy(destPath);
      return destPath;
    } catch (_) {
      return sourcePath;
    }
  }

  Future<void> clearProfileImage() async {
    final path = _prefs.getString(imagePathKey);
    await _prefs.remove(imagePathKey);
    if (!kIsWeb && path != null && path.isNotEmpty) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }
}
