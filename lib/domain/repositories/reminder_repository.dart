import 'package:mindloop/domain/entities/reminder_entity.dart';

abstract class ReminderRepository {
  Future<List<ReminderEntity>> getReminders();
  Future<ReminderEntity?> getReminderById(String id);
  Future<void> saveReminder(ReminderEntity reminder);
  Future<void> deleteReminder(String id);
  Future<void> markCompleted(String id, bool completed);
}
