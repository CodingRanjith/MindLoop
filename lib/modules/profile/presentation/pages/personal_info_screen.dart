import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/app/di/injection.dart';
import 'package:mindloop/core/utils/local_file_image.dart';
import 'package:mindloop/modules/profile/core/utils/user_profile_store.dart';
import 'package:mindloop/modules/profile/domain/entities/user_profile.dart';
import 'package:mindloop/shared/theme/app_colors.dart';
import 'package:mindloop/shared/widgets/app_feedback.dart';
import 'package:mindloop/shared/widgets/glow_button.dart';

/// Personal profile form — name, DOB, gender, profile image only.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final UserProfileStore _store;
  late final TextEditingController _nameController;
  final _picker = ImagePicker();
  final _dateFmt = DateFormat('d MMM yyyy');

  UserProfile _profile = const UserProfile();
  bool _saving = false;
  String? _pendingImagePath;

  @override
  void initState() {
    super.initState();
    _store = UserProfileStore(sl());
    _profile = _store.load();
    _pendingImagePath = _profile.profileImagePath;
    _nameController = TextEditingController(text: _profile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() => _pendingImagePath = file.path);
    } on PlatformException {
      if (mounted) {
        AppFeedback.showError(context, 'Could not access camera or gallery.');
      }
    }
  }

  Future<void> _showImageOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_pendingImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.expense),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(color: AppColors.expense),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _pendingImagePath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial = _profile.dateOfBirth ?? DateTime(now.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Date of birth',
    );
    if (picked != null && mounted) {
      setState(() => _profile = _profile.copyWith(dateOfBirth: picked));
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppFeedback.showError(context, 'Please enter your name.');
      return;
    }
    if (_profile.dateOfBirth == null) {
      AppFeedback.showError(context, 'Please select your date of birth.');
      return;
    }
    if (_profile.gender.isEmpty) {
      AppFeedback.showError(context, 'Please select your gender.');
      return;
    }

    setState(() => _saving = true);
    try {
      String? imagePath = _profile.profileImagePath;
      if (_pendingImagePath != _profile.profileImagePath) {
        if (_pendingImagePath == null) {
          await _store.clearProfileImage();
          imagePath = null;
        } else {
          imagePath = await _store.persistProfileImage(_pendingImagePath!);
        }
      }

      final updated = UserProfile(
        name: name,
        dateOfBirth: _profile.dateOfBirth,
        gender: _profile.gender,
        profileImagePath: imagePath,
      );
      await _store.save(updated);
      if (mounted) {
        AppFeedback.showSuccess(context, 'Profile saved locally.');
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Could not save profile.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayPath = _pendingImagePath ?? _profile.profileImagePath;
    final hasImage = LocalFileImage.canShowFile(displayPath);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Personal Information'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: GestureDetector(
              onTap: _showImageOptions,
              child: Stack(
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceMuted,
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: hasImage
                        ? LocalFileImage(
                            path: displayPath!,
                            width: 112,
                            height: 112,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person_outline,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Profile photo',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDateOfBirth,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              child: Text(
                _profile.dateOfBirth != null
                    ? _dateFmt.format(_profile.dateOfBirth!)
                    : 'Select date',
                style: TextStyle(
                  fontSize: 16,
                  color: _profile.dateOfBirth != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _profile.gender.isEmpty ? null : _profile.gender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(Icons.wc_outlined),
            ),
            hint: const Text('Select gender'),
            items: UserProfileStore.genderOptions
                .map(
                  (g) => DropdownMenuItem(value: g, child: Text(g)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _profile = _profile.copyWith(gender: value));
              }
            },
          ),
          const SizedBox(height: 32),
          GlowButton(
            label: _saving ? 'Saving…' : 'Save profile',
            onPressed: _saving ? null : _save,
          ),
          const SizedBox(height: 16),
          const Text(
            'Stored only on this device (SharedPreferences). No cloud or database.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
