part of 'reminder_bloc.dart';

class ReminderState extends Equatable {
  const ReminderState({
    this.reminders = const [],
    this.todayReminders = const [],
    this.upcomingReminders = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.saveSucceeded = false,
    this.error,
    this.permissionWarning,
  });

  final List<ReminderEntity> reminders;
  final List<ReminderEntity> todayReminders;
  final List<ReminderEntity> upcomingReminders;
  final bool isLoading;
  final bool isSaving;
  final bool saveSucceeded;
  final String? error;
  final String? permissionWarning;

  ReminderState copyWith({
    List<ReminderEntity>? reminders,
    List<ReminderEntity>? todayReminders,
    List<ReminderEntity>? upcomingReminders,
    bool? isLoading,
    bool? isSaving,
    bool? saveSucceeded,
    String? error,
    String? permissionWarning,
    bool clearError = false,
    bool clearPermissionWarning = false,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      todayReminders: todayReminders ?? this.todayReminders,
      upcomingReminders: upcomingReminders ?? this.upcomingReminders,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSucceeded: saveSucceeded ?? this.saveSucceeded,
      error: clearError ? null : (error ?? this.error),
      permissionWarning: clearPermissionWarning
          ? null
          : (permissionWarning ?? this.permissionWarning),
    );
  }

  @override
  List<Object?> get props => [
        reminders,
        todayReminders,
        upcomingReminders,
        isLoading,
        isSaving,
        saveSucceeded,
        error,
        permissionWarning,
      ];
}
