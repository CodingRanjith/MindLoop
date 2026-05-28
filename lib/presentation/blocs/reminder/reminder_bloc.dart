import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/domain/entities/reminder_entity.dart';
import 'package:mindloop/domain/repositories/reminder_repository.dart';
import 'package:mindloop/services/notification_service.dart';
import 'package:uuid/uuid.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  ReminderBloc(this._repository, this._notifications)
      : super(const ReminderState()) {
    on<RemindersLoadRequested>(_onLoad);
    on<ReminderSaveRequested>(_onSave);
    on<ReminderDeleteRequested>(_onDelete);
  }

  final ReminderRepository _repository;
  final NotificationService _notifications;
  final _uuid = const Uuid();

  Future<void> _onLoad(
    RemindersLoadRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final reminders = await _repository.getReminders();
      final now = DateTime.now();
      final today = reminders
          .where((r) =>
              !r.isCompleted &&
              r.scheduledAt.year == now.year &&
              r.scheduledAt.month == now.month &&
              r.scheduledAt.day == now.day)
          .toList();
      final upcoming = reminders
          .where((r) => !r.isCompleted && r.scheduledAt.isAfter(now))
          .toList();
      emit(state.copyWith(
        reminders: reminders,
        todayReminders: today,
        upcomingReminders: upcoming,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSave(
    ReminderSaveRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveSucceeded: false, clearError: true));

    final reminder = event.reminder.copyWith(
      id: event.reminder.id.isEmpty ? _uuid.v4() : event.reminder.id,
    );

    if (!reminder.scheduledAt.isAfter(DateTime.now())) {
      emit(state.copyWith(
        isSaving: false,
        error: 'Please choose a date and time in the future',
      ));
      return;
    }

    try {
      await _notifications.requestPermissions();
      await _repository.saveReminder(reminder);
      await _notifications.scheduleReminder(reminder);
      add(const RemindersLoadRequested());
      emit(state.copyWith(isSaving: false, saveSucceeded: true));
      emit(state.copyWith(saveSucceeded: false));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: 'Could not save reminder: $e',
      ));
    }
  }

  Future<void> _onDelete(
    ReminderDeleteRequested event,
    Emitter<ReminderState> emit,
  ) async {
    await _repository.deleteReminder(event.id);
    await _notifications.cancelReminder(event.id);
    add(const RemindersLoadRequested());
  }
}
