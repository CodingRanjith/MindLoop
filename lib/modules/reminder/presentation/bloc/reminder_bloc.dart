import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mindloop/modules/reminder/domain/entities/reminder_entity.dart';

import 'package:mindloop/modules/reminder/domain/repositories/reminder_repository.dart';

import 'package:mindloop/core/services/notification_service.dart';

import 'package:mindloop/modules/reminder/services/reminder_alarm_coordinator.dart';

import 'package:uuid/uuid.dart';



part 'reminder_event.dart';

part 'reminder_state.dart';



class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {

  ReminderBloc(this._repository, this._notifications)

      : super(const ReminderState()) {

    on<RemindersLoadRequested>(_onLoad);

    on<ReminderSaveRequested>(_onSave);

    on<ReminderDeleteRequested>(_onDelete);

    on<ReminderSnoozeRequested>(_onSnooze);

    on<ReminderDismissRequested>(_onDismiss);

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

      await _notifications.rescheduleAll(reminders);



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



  bool _isScheduleInFuture(ReminderEntity reminder) =>

      reminder.scheduledAt.isAfter(DateTime.now());



  bool _scheduleTimeUnchanged(ReminderEntity reminder) {

    for (final r in state.reminders) {

      if (r.id == reminder.id) {

        return r.scheduledAt == reminder.scheduledAt;

      }

    }

    return false;

  }



  Future<void> _onSave(

    ReminderSaveRequested event,

    Emitter<ReminderState> emit,

  ) async {

    emit(state.copyWith(

      isSaving: true,

      saveSucceeded: false,

      clearError: true,

      clearPermissionWarning: true,

    ));



    final reminder = event.reminder.copyWith(

      id: event.reminder.id.isEmpty ? _uuid.v4() : event.reminder.id,

    );



    if (!_isScheduleInFuture(reminder) && !_scheduleTimeUnchanged(reminder)) {

      emit(state.copyWith(

        isSaving: false,

        error: 'Please choose a date and time in the future',

      ));

      return;

    }



    try {

      final alarmsReady = await _notifications.checkPermissions();

      await _repository.saveReminder(reminder);

      await _notifications.cancelReminder(reminder.id);

      if (_isScheduleInFuture(reminder) && !reminder.isCompleted) {

        await _notifications.scheduleReminder(reminder);

      }

      ReminderAlarmCoordinator.clearFired(reminder.id);

      add(const RemindersLoadRequested());

      emit(state.copyWith(

        isSaving: false,

        saveSucceeded: true,

        permissionWarning: alarmsReady

            ? null

            : 'Allow Notifications, Alarms & reminders, and disable battery restriction for MindLoop.',

      ));

    } catch (e) {

      emit(state.copyWith(

        isSaving: false,

        error: 'Could not save reminder: $e',

      ));

    }

  }



  Future<void> _onSnooze(

    ReminderSnoozeRequested event,

    Emitter<ReminderState> emit,

  ) async {

    final existing = await _repository.getReminderById(event.id);

    if (existing == null || existing.isCompleted) return;



    final snoozed = existing.copyWith(

      scheduledAt: DateTime.now().add(event.duration),

    );

    await _repository.saveReminder(snoozed);

    await _notifications.cancelReminder(event.id);

    await _notifications.scheduleReminder(snoozed);

    ReminderAlarmCoordinator.clearFired(event.id);

    add(const RemindersLoadRequested());

  }



  Future<void> _onDismiss(

    ReminderDismissRequested event,

    Emitter<ReminderState> emit,

  ) async {

    await _notifications.cancelReminder(event.id);

    ReminderAlarmCoordinator.clearFired(event.id);

    if (event.markComplete) {

      await _repository.markCompleted(event.id, true);

      add(const RemindersLoadRequested());

    }

  }



  Future<void> _onDelete(

    ReminderDeleteRequested event,

    Emitter<ReminderState> emit,

  ) async {

    await _repository.deleteReminder(event.id);

    await _notifications.cancelReminder(event.id);

    ReminderAlarmCoordinator.clearFired(event.id);

    add(const RemindersLoadRequested());

  }

}

