import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_status.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_cycle_record.dart';

/// Completed, pending and missed reminders of one group, as counted on the routines screen.
class RoutineCount {
  final int completed;
  final int pending;
  final int missed;

  const new({required this.completed, required this.pending, required this.missed});

  int get total => completed + pending + missed;

  int get percentage => total == 0 ? 0 : completed * 100 ~/ total;
}

class RoutinesState {
  const new({
    this.isLoading = false,
    this.isLoaded = false,
    this.errorMessage,
    this.careRecipientName = '',
    this.todayReminders = const [],
    this.nextAppointment,
    this.hydrationPlan,
    this.lastSleep,
    this.activityMonitor,
    this.medicationStocks = const [],
    required this.now,
  });

  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;
  final String careRecipientName;
  final List<Reminder> todayReminders;
  final Reminder? nextAppointment;
  // The optional sections stay null when the platform has nothing yet (no plan, no telemetry)
  final HydrationPlan? hydrationPlan;
  final SleepCycleRecord? lastSleep;
  final ActivityMonitor? activityMonitor;
  final List<MedicationStock> medicationStocks;
  // Time of the last refresh; "EN 25 MIN" and "Hace 1 min" are measured against it
  final DateTime now;

  // Hydration follows its own plan, and its later occurrences of the day do not exist yet on the
  // platform (one occurrence at a time), so counting them would understate the day
  List<Reminder> get _dayReminders => todayReminders
      .where((reminder) => reminder.type != ReminderType.hydration && reminder.status.countsTowardsDay)
      .toList();

  RoutineCount get today => _countOf(_dayReminders);

  Reminder? get nextReminder {
    final pending = _dayReminders.where((reminder) => reminder.status.isPending).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return pending.firstOrNull;
  }

  RoutineCount countOf(ReminderType type) => _countOf(_dayReminders.where((reminder) => reminder.type == type));

  /// The medication that runs out first.
  MedicationStock? get lowestStock {
    if (medicationStocks.isEmpty) return null;
    return medicationStocks.reduce((a, b) => b.remainingDaysOfSupply < a.remainingDaysOfSupply ? b : a);
  }

  RoutineCount _countOf(Iterable<Reminder> reminders) {
    return RoutineCount(
      completed: reminders.where((reminder) => reminder.status == ReminderStatus.confirmed).length,
      pending: reminders.where((reminder) => reminder.status.isPending).length,
      missed: reminders.where((reminder) => reminder.status == ReminderStatus.missed).length,
    );
  }

  // Nullable fields take a function, so copyWith can also set them back to null
  RoutinesState copyWith({
    bool? isLoading,
    bool? isLoaded,
    ValueGetter<String?>? errorMessage,
    List<Reminder>? todayReminders,
    ValueGetter<Reminder?>? nextAppointment,
    ValueGetter<HydrationPlan?>? hydrationPlan,
    ValueGetter<SleepCycleRecord?>? lastSleep,
    ValueGetter<ActivityMonitor?>? activityMonitor,
    List<MedicationStock>? medicationStocks,
    DateTime? now,
  }) {
    return RoutinesState(
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      careRecipientName: careRecipientName,
      todayReminders: todayReminders ?? this.todayReminders,
      nextAppointment: nextAppointment != null ? nextAppointment() : this.nextAppointment,
      hydrationPlan: hydrationPlan != null ? hydrationPlan() : this.hydrationPlan,
      lastSleep: lastSleep != null ? lastSleep() : this.lastSleep,
      activityMonitor: activityMonitor != null ? activityMonitor() : this.activityMonitor,
      medicationStocks: medicationStocks ?? this.medicationStocks,
      now: now ?? this.now,
    );
  }
}
