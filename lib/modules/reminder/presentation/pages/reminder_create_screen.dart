import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/modules/reminder/core/constants/reminder_categories.dart';
import 'package:mindloop/modules/reminder/core/constants/reminder_ringtones.dart';
import 'package:mindloop/app/di/injection.dart';
import 'package:mindloop/core/utils/local_file_image.dart';
import 'package:mindloop/modules/reminder/core/utils/reminder_audio_permissions.dart';
import 'package:mindloop/modules/reminder/core/utils/reminder_sound_player.dart';
import 'package:mindloop/modules/reminder/domain/entities/reminder_entity.dart';
import 'package:mindloop/modules/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:mindloop/modules/reminder/services/custom_ringtone_service.dart';
import 'package:mindloop/shared/theme/app_colors.dart';
import 'package:mindloop/shared/widgets/app_list_rows.dart';
import 'package:mindloop/shared/widgets/glow_button.dart';

enum _SoundSource { builtIn, folder, file }

class ReminderCreateScreen extends StatefulWidget {
  const ReminderCreateScreen({super.key, this.initialReminder});

  final ReminderEntity? initialReminder;

  @override
  State<ReminderCreateScreen> createState() => _ReminderCreateScreenState();
}

class _ReminderCreateScreenState extends State<ReminderCreateScreen> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  DateTime _scheduled = DateTime.now().add(const Duration(hours: 1));
  ReminderCategory _category = ReminderCategory.personal;
  String? _imagePath;
  String? _repeatRule;
  String _ringtoneId = ReminderRingtones.defaultId;
  _SoundSource _soundSource = _SoundSource.builtIn;
  String? _customMusicPath;
  String? _musicFolderPath;
  List<CustomAudioTrack> _folderTracks = [];
  String? _selectedFolderTrackPath;

  final _picker = ImagePicker();
  final _previewPlayer = AudioPlayer();
  final _dateFmt = DateFormat('EEE, MMM d · h:mm a');
  late final CustomRingtoneService _ringtones;
  bool get _isEditMode => widget.initialReminder != null;

  @override
  void initState() {
    super.initState();
    _ringtones = sl<CustomRingtoneService>();
    _prefillForEdit();
    _loadFolderTracks();
  }

  void _prefillForEdit() {
    final initial = widget.initialReminder;
    if (initial == null) return;
    _title.text = initial.title;
    _note.text = initial.note ?? '';
    _scheduled = initial.scheduledAt;
    _category = initial.category;
    _imagePath = initial.imagePath;
    _repeatRule = initial.repeatRule;

    final musicAsset = initial.musicAsset;
    if (musicAsset == null || musicAsset.isEmpty) return;

    final builtIn = ReminderRingtones.all
        .where((r) => r.assetPath == musicAsset)
        .toList();
    if (builtIn.isNotEmpty) {
      _soundSource = _SoundSource.builtIn;
      _ringtoneId = builtIn.first.id;
      return;
    }

    _soundSource = _SoundSource.file;
    _customMusicPath = musicAsset;
  }

  void _loadFolderTracks() {
    final folder = _ringtones.savedFolderPath;
    final tracks = _ringtones.tracksFromSavedFolder();
    setState(() {
      _musicFolderPath = folder;
      _folderTracks = tracks;
      if (tracks.isNotEmpty &&
          _selectedFolderTrackPath == null &&
          _soundSource == _SoundSource.folder) {
        _selectedFolderTrackPath = tracks.first.path;
        _customMusicPath = tracks.first.storedValue;
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _previewPlayer.dispose();
    super.dispose();
  }

  String? get _resolvedMusicAsset {
    return switch (_soundSource) {
      _SoundSource.builtIn => ReminderRingtones.assetForId(_ringtoneId),
      _SoundSource.folder || _SoundSource.file => _customMusicPath,
    };
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduled.isBefore(now) ? now : _scheduled,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduled),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduled = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _imagePath = file.path);
  }

  Future<void> _previewSound() async {
    if (_soundSource != _SoundSource.builtIn) {
      final allowed = await ReminderAudioPermissions.ensureForCustomSound();
      if (!allowed && mounted) {
        _showSnack('Allow audio access to preview your selected ringtone.');
        return;
      }
    }

    await _previewPlayer.setReleaseMode(ReleaseMode.release);
    final ok = await ReminderSoundPlayer.tryPlay(
      _previewPlayer,
      _resolvedMusicAsset,
    );
    if (!ok && mounted) {
      _showSnack(
        kIsWeb
            ? 'Could not preview this sound in the browser. Try on the mobile app.'
            : 'Could not play this sound. Check permissions and file access.',
      );
    }
  }

  Future<void> _pickMusicFolder() async {
    if (kIsWeb) {
      _showSnack('Folder pick works on desktop and mobile apps. Use “Pick audio file” on web.');
      return;
    }
    final allowed = await ReminderAudioPermissions.ensureForCustomSound();
    if (!allowed) {
      _showSnack('Allow audio access to use music from your folder.');
      return;
    }
    final path = await _ringtones.pickMusicFolder();
    if (path == null) return;
    final tracks = _ringtones.listTracksInFolder(path);
    setState(() {
      _soundSource = _SoundSource.folder;
      _musicFolderPath = path;
      _folderTracks = tracks;
      _selectedFolderTrackPath = tracks.isNotEmpty ? tracks.first.path : null;
      _customMusicPath = tracks.isNotEmpty ? tracks.first.storedValue : null;
    });
    if (tracks.isEmpty) {
      _showSnack('No audio files found in this folder.');
    }
  }

  Future<void> _pickSingleAudio() async {
    if (!kIsWeb) {
      final allowed = await ReminderAudioPermissions.ensureForCustomSound();
      if (!allowed) {
        _showSnack('Allow audio access to pick a custom ringtone.');
        return;
      }
    }
    final path = await _ringtones.pickSingleAudioFile();
    if (path == null || path.isEmpty) return;
    setState(() {
      _soundSource = _SoundSource.file;
      _customMusicPath = ReminderSoundPlayer.toStoredFilePath(path);
      _selectedFolderTrackPath = null;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      _showSnack('Title is required');
      return;
    }
    if (_soundSource != _SoundSource.builtIn &&
        (_customMusicPath == null || _customMusicPath!.isEmpty)) {
      _showSnack('Choose an alarm sound');
      return;
    }

    if (!kIsWeb) {
      await ReminderAudioPermissions.ensureBackgroundAlarmsReady();
      if (_soundSource != _SoundSource.builtIn) {
        await ReminderAudioPermissions.ensureForCustomSound();
      }
    }

    final reminder = ReminderEntity(
      id: widget.initialReminder?.id ?? '',
      title: _title.text.trim(),
      scheduledAt: _scheduled,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      imagePath: _imagePath,
      musicAsset: _resolvedMusicAsset,
      category: _category,
      repeatRule: _repeatRule,
      isCompleted: widget.initialReminder?.isCompleted ?? false,
    );
    if (!mounted) return;
    context.read<ReminderBloc>().add(ReminderSaveRequested(reminder));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReminderBloc, ReminderState>(
      listenWhen: (prev, curr) =>
          prev.saveSucceeded != curr.saveSucceeded && curr.saveSucceeded,
      listener: (context, state) {
        if (state.permissionWarning != null) {
          _showSnack(state.permissionWarning!);
        } else {
          _showSnack(
            _isEditMode
                ? 'Reminder updated & alarm rescheduled'
                : 'Reminder saved & alarm scheduled',
          );
        }
        context.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Reminder' : 'Create Reminder'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<ReminderBloc, ReminderState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionTitle(title: 'Details'),
                  const SizedBox(height: 10),
                  _FormCard(
                    children: [
                      TextField(
                        controller: _title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'What should we remind you?',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _note,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Optional details',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Schedule'),
                  const SizedBox(height: 10),
                  _FormCard(
                    children: [
                      _TappableRow(
                        label: 'Date & time',
                        value: _dateFmt.format(_scheduled),
                        icon: Icons.schedule_outlined,
                        onTap: _pickDateTime,
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ReminderCategory.values.map((c) {
                          final selected = _category == c;
                          return FilterChip(
                            label: Text(c.label),
                            selected: selected,
                            onSelected: (_) => setState(() => _category = c),
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppColors.textOnPrimary
                                  : AppColors.textPrimary,
                            ),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceMuted,
                            side: BorderSide(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          );
                        }).toList(),
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      AppSwitchRow(
                        title: 'Repeat daily',
                        value: _repeatRule == 'daily',
                        onChanged: (v) =>
                            setState(() => _repeatRule = v ? 'daily' : null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Alarm sound'),
                  const SizedBox(height: 10),
                  _FormCard(
                    children: [
                      SegmentedButton<_SoundSource>(
                        segments: const [
                          ButtonSegment(
                            value: _SoundSource.builtIn,
                            label: Text('Built-in'),
                            icon: Icon(Icons.library_music_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: _SoundSource.folder,
                            label: Text('My folder'),
                            icon: Icon(Icons.folder_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: _SoundSource.file,
                            label: Text('Pick file'),
                            icon: Icon(Icons.audio_file_outlined, size: 18),
                          ),
                        ],
                        selected: {_soundSource},
                        onSelectionChanged: (set) {
                          final next = set.first;
                          setState(() {
                            _soundSource = next;
                            if (next == _SoundSource.builtIn) {
                              _customMusicPath = null;
                            } else if (next == _SoundSource.folder &&
                                _folderTracks.isNotEmpty) {
                              _selectedFolderTrackPath = _folderTracks.first.path;
                              _customMusicPath = _folderTracks.first.storedValue;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_soundSource == _SoundSource.builtIn) ...[
                        ...ReminderRingtones.all.map((r) {
                          return AppRadioRow<String>(
                            value: r.id,
                            groupValue: _ringtoneId,
                            title: r.label,
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _ringtoneId = v);
                              _previewSound();
                            },
                          );
                        }),
                      ] else if (_soundSource == _SoundSource.folder) ...[
                        OutlinedButton.icon(
                          onPressed: _pickMusicFolder,
                          icon: const Icon(Icons.folder_open_outlined),
                          label: Text(
                            _musicFolderPath == null
                                ? 'Choose music folder'
                                : 'Change folder',
                          ),
                        ),
                        if (_musicFolderPath != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _musicFolderPath!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (_folderTracks.isEmpty)
                          const Text(
                            kIsWeb
                                ? 'Folder scanning is not available in the browser.'
                                : 'No audio files in folder. Supported: mp3, wav, ogg, m4a, aac, flac.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedFolderTrackPath,
                            decoration: const InputDecoration(
                              labelText: 'Track from folder',
                            ),
                            items: _folderTracks
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t.path,
                                    child: Text(t.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (path) {
                              if (path == null) return;
                              final track = _folderTracks.firstWhere(
                                (t) => t.path == path,
                              );
                              setState(() {
                                _selectedFolderTrackPath = path;
                                _customMusicPath = track.storedValue;
                              });
                            },
                          ),
                      ] else ...[
                        OutlinedButton.icon(
                          onPressed: _pickSingleAudio,
                          icon: const Icon(Icons.upload_file_outlined),
                          label: const Text('Choose audio file'),
                        ),
                        if (_customMusicPath != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: AppColors.income,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ReminderSoundPlayer.filePathFromStored(
                                    _customMusicPath!,
                                  ).split(RegExp(r'[/\\]')).last,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _previewSound,
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: const Text('Preview sound'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Attachment'),
                  const SizedBox(height: 10),
                  _FormCard(
                    children: [
                      _TappableRow(
                        label: _imagePath == null ? 'Add image' : 'Change image',
                        value: _imagePath == null
                            ? 'Optional photo for alert screen'
                            : 'Image attached',
                        icon: Icons.image_outlined,
                        onTap: _pickImage,
                        trailing: LocalFileImage.canShowFile(_imagePath)
                            ? LocalFileImage(
                                path: _imagePath!,
                                width: 44,
                                height: 44,
                                borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                      ),
                    ],
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 28),
                  GlowButton(
                    label: _isEditMode ? 'Update Reminder' : 'Save Reminder',
                    isLoading: state.isSaving,
                    onPressed: state.isSaving ? null : _save,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.7,
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _TappableRow extends StatelessWidget {
  const _TappableRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null)
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
