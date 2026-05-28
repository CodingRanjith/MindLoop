import 'package:equatable/equatable.dart';
import 'package:mindloop/core/constants/reminder_categories.dart';

class ReminderEntity extends Equatable {
  const ReminderEntity({
    required this.id,
    required this.title,
    required this.scheduledAt,
    this.note,
    this.imagePath,
    this.musicAsset,
    this.category = ReminderCategory.personal,
    this.repeatRule,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final DateTime scheduledAt;
  final String? note;
  final String? imagePath;
  final String? musicAsset;
  final ReminderCategory category;
  final String? repeatRule;
  final bool isCompleted;

  ReminderEntity copyWith({
    String? id,
    String? title,
    DateTime? scheduledAt,
    String? note,
    String? imagePath,
    String? musicAsset,
    ReminderCategory? category,
    String? repeatRule,
    bool? isCompleted,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      musicAsset: musicAsset ?? this.musicAsset,
      category: category ?? this.category,
      repeatRule: repeatRule ?? this.repeatRule,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        scheduledAt,
        note,
        imagePath,
        musicAsset,
        category,
        repeatRule,
        isCompleted,
      ];
}
