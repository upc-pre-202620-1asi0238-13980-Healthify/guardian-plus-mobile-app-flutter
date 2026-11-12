import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/adherence.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_status.dart';

class MedicationState {
  const new({
    this.isLoading = false,
    this.isLoaded = false,
    this.errorMessage,
    this.todayReminders = const [],
    this.weeklyAdherence,
    required this.now,
    this.busyReminderId,
    this.message,
  });

  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;
  final List<Reminder> todayReminders;
  // Null when the platform could not measure it; the rest of the screen still shows
  final Adherence? weeklyAdherence;
  final DateTime now;
  // Dose being confirmed or marked as missed, so only its button shows progress
  final String? busyReminderId;
  final String? message;

  /// Today's doses that are the person's responsibility, in the order of the day.
  List<Reminder> get doses {
    return todayReminders.where((reminder) => reminder.status.countsTowardsDay).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  int get takenCount => doses.where((dose) => dose.status == ReminderStatus.confirmed).length;

  /// The dose the person has to take next: the one already issued, or the next scheduled.
  Reminder? get nextDose => doses.where((dose) => dose.status.isPending).firstOrNull;

  /// Doses reissued after 10 minutes without confirmation, waiting for the family to review them.
  List<Reminder> get unconfirmedDoses => doses.where((dose) => dose.status == ReminderStatus.reissued).toList();

  // Nullable fields take a function, so copyWith can also set them back to null
  MedicationState copyWith({
    bool? isLoading,
    bool? isLoaded,
    ValueGetter<String?>? errorMessage,
    List<Reminder>? todayReminders,
    ValueGetter<Adherence?>? weeklyAdherence,
    DateTime? now,
    ValueGetter<String?>? busyReminderId,
    ValueGetter<String?>? message,
  }) {
    return MedicationState(
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      todayReminders: todayReminders ?? this.todayReminders,
      weeklyAdherence: weeklyAdherence != null ? weeklyAdherence() : this.weeklyAdherence,
      now: now ?? this.now,
      busyReminderId: busyReminderId != null ? busyReminderId() : this.busyReminderId,
      message: message != null ? message() : this.message,
    );
  }
}
