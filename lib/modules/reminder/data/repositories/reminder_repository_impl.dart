import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindloop/core/constants/app_constants.dart';
import 'package:mindloop/modules/reminder/data/models/reminder_model.dart';
import 'package:mindloop/modules/reminder/domain/entities/reminder_entity.dart';
import 'package:mindloop/modules/reminder/domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(AppConstants.hiveRemindersBox);
    return _box!;
  }

  @override
  Future<ReminderEntity?> getReminderById(String id) async {
    final b = await box;
    final raw = b.get(id);
    if (raw == null) return null;
    return ReminderModel.fromJson(Map<String, dynamic>.from(raw)).toEntity();
  }

  @override
  Future<List<ReminderEntity>> getReminders() async {
    final b = await box;
    return b.values
        .map((e) => ReminderModel.fromJson(Map<String, dynamic>.from(e)).toEntity())
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  @override
  Future<void> saveReminder(ReminderEntity reminder) async {
    final b = await box;
    final model = ReminderModel.fromEntity(reminder);
    await b.put(reminder.id, model.toJson());
  }

  @override
  Future<void> deleteReminder(String id) async {
    final b = await box;
    await b.delete(id);
  }

  @override
  Future<void> markCompleted(String id, bool completed) async {
    final b = await box;
    final raw = b.get(id);
    if (raw == null) return;
    final model = ReminderModel.fromJson(Map<String, dynamic>.from(raw));
    await b.put(id, model.copyWith(isCompleted: completed).toJson());
  }
}

extension on ReminderModel {
  ReminderModel copyWith({bool? isCompleted}) {
    return ReminderModel(
      id: id,
      title: title,
      scheduledAt: scheduledAt,
      note: note,
      imagePath: imagePath,
      musicAsset: musicAsset,
      category: category,
      repeatRule: repeatRule,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
