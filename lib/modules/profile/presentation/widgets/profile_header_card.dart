import 'package:flutter/material.dart';
import 'package:mindloop/core/utils/local_file_image.dart';
import 'package:mindloop/modules/profile/domain/entities/user_profile.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    this.subtitle,
  });

  final UserProfile profile;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final name = profile.name.trim().isEmpty ? 'Your profile' : profile.name.trim();
    final sub = subtitle ?? _buildSubtitle();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: PfmTheme.profileGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: PfmTheme.cardShadow,
      ),
      child: Row(
        children: [
          _Avatar(profile: profile),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (profile.gender.isNotEmpty) parts.add(profile.gender);
    if (profile.dateOfBirth != null) {
      final d = profile.dateOfBirth!;
      parts.add('${d.day}/${d.month}/${d.year}');
    }
    if (parts.isEmpty) return 'Tap Personal Information to complete';
    return parts.join(' · ');
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final hasImage = LocalFileImage.canShowFile(profile.profileImagePath);
    if (hasImage) {
      return ClipOval(
        child: LocalFileImage(
          path: profile.profileImagePath!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
        ),
      );
    }
    return CircleAvatar(
      radius: 36,
      backgroundColor: Colors.white.withValues(alpha: 0.25),
      child: Text(
        profile.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
