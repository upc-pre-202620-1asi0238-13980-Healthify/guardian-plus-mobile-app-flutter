import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/adherence.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_status.dart';

class ActivityState {
  const new({
    this.isLoading = false,
    this.isLoaded = false,
    this.errorMessage,
    this.todayReminders = const [],
    this.weeklyAdherence,
    required this.now,
    this.busyReminderId,
    this.isAdding = false,
    this.isSaving = false,
    this.message,
  });

  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;
  final List<Reminder> todayReminders;
  final Adherence? weeklyAdherence;
  final DateTime now;
  final String? busyReminderId;
  // "+" swaps the plan for the "Nueva actividad" form, as in the prototype
  final bool isAdding;
  final bool isSaving;
  final String? message;

  List<Reminder> get blocks {
    return todayReminders.where((reminder) => reminder.status.countsTowardsDay).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  int get completedCount => blocks.where((block) => block.status == ReminderStatus.confirmed).length;

  int get percentage => blocks.isEmpty ? 0 : completedCount * 100 ~/ blocks.length;

  Reminder? get nextBlock => blocks.where((block) => block.status.isPending).firstOrNull;

  // Nullable fields take a function, so copyWith can also set them back to null
  ActivityState copyWith({
    bool? isLoading,
    bool? isLoaded,
    ValueGetter<String?>? errorMessage,
    List<Reminder>? todayReminders,
    ValueGetter<Adherence?>? weeklyAdherence,
    DateTime? now,
    ValueGetter<String?>? busyReminderId,
    bool? isAdding,
    bool? isSaving,
    ValueGetter<String?>? message,
  }) {
    return ActivityState(
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      todayReminders: todayReminders ?? this.todayReminders,
      weeklyAdherence: weeklyAdherence != null ? weeklyAdherence() : this.weeklyAdherence,
      now: now ?? this.now,
      busyReminderId: busyReminderId != null ? busyReminderId() : this.busyReminderId,
      isAdding: isAdding ?? this.isAdding,
      isSaving: isSaving ?? this.isSaving,
      message: message != null ? message() : this.message,
    );
  }
}
