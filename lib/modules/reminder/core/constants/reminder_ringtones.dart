class ReminderRingtone {
  const ReminderRingtone({
    required this.id,
    required this.label,
    required this.assetPath,
  });

  final String id;
  final String label;
  final String assetPath;
}

class ReminderRingtones {
  ReminderRingtones._();

  static const defaultId = 'chime';

  static const List<ReminderRingtone> all = [
    ReminderRingtone(
      id: 'chime',
      label: 'Crystal Chime',
      assetPath: 'sounds/chime.wav',
    ),
    ReminderRingtone(
      id: 'soft_bell',
      label: 'Soft Bell',
      assetPath: 'sounds/soft_bell.wav',
    ),
    ReminderRingtone(
      id: 'alert',
      label: 'Bright Alert',
      assetPath: 'sounds/alert.wav',
    ),
    ReminderRingtone(
      id: 'gentle_pulse',
      label: 'Gentle Pulse',
      assetPath: 'sounds/gentle_pulse.wav',
    ),
  ];

  static ReminderRingtone byId(String? id) {
    return all.firstWhere(
      (r) => r.id == id,
      orElse: () => all.first,
    );
  }

  static String assetForId(String? id) => byId(id).assetPath;

  static String get defaultAsset => assetForId(defaultId);
}
