part of 'reminder_bloc.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class RemindersLoadRequested extends ReminderEvent {
  const RemindersLoadRequested();
}

class ReminderSaveRequested extends ReminderEvent {
  const ReminderSaveRequested(this.reminder);
  final ReminderEntity reminder;

  @override
  List<Object?> get props => [reminder];
}

class ReminderDeleteRequested extends ReminderEvent {
  const ReminderDeleteRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
