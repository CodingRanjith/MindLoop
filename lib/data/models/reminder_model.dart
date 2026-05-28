import 'package:mindloop/core/constants/reminder_categories.dart';
import 'package:mindloop/domain/entities/reminder_entity.dart';

class ReminderModel {
  ReminderModel({
    required this.id,
    required this.title,
    required this.scheduledAt,
    this.note,
    this.imagePath,
    this.musicAsset,
    this.category = 'personal',
    this.repeatRule,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final DateTime scheduledAt;
  final String? note;
  final String? imagePath;
  final String? musicAsset;
  final String category;
  final String? repeatRule;
  final bool isCompleted;

  factory ReminderModel.fromEntity(ReminderEntity entity) {
    return ReminderModel(
      id: entity.id,
      title: entity.title,
      scheduledAt: entity.scheduledAt,
      note: entity.note,
      imagePath: entity.imagePath,
      musicAsset: entity.musicAsset,
      category: entity.category.name,
      repeatRule: entity.repeatRule,
      isCompleted: entity.isCompleted,
    );
  }

  ReminderEntity toEntity() {
    return ReminderEntity(
      id: id,
      title: title,
      scheduledAt: scheduledAt,
      note: note,
      imagePath: imagePath,
      musicAsset: musicAsset,
      category: ReminderCategoryX.fromString(category),
      repeatRule: repeatRule,
      isCompleted: isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'scheduledAt': scheduledAt.toIso8601String(),
        'note': note,
        'imagePath': imagePath,
        'musicAsset': musicAsset,
        'category': category,
        'repeatRule': repeatRule,
        'isCompleted': isCompleted,
      };

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      note: json['note'] as String?,
      imagePath: json['imagePath'] as String?,
      musicAsset: json['musicAsset'] as String?,
      category: json['category'] as String? ?? 'personal',
      repeatRule: json['repeatRule'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
