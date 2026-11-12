import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/confirm_reminder_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_adherence_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_reminders_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/schedule_reminder_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/schedule_reminder_request.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/activity/activity_state.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_day.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';

/// "Actividad ligera": today's mobility blocks, how many were done and the last week.
class ActivityViewModel extends ChangeNotifier implements RoutineMessageSource {
  final GetRemindersUseCase getReminders;
  final GetAdherenceUseCase getAdherence;
  final ConfirmReminderUseCase confirmReminder;
  final ScheduleReminderUseCase scheduleReminder;
  final CareContextStore careContextStore;

  new({
    required this.getReminders,
    required this.getAdherence,
    required this.confirmReminder,
    required this.scheduleReminder,
    required this.careContextStore,
  }) {
    load();
    _autoRefresh = Timer.periodic(_autoRefreshInterval, (_) {
      if (!_state.isLoading && _state.busyReminderId == null && !_state.isSaving) _refresh();
    });
  }

  static const _autoRefreshInterval = Duration(seconds: 30);

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  ActivityState _state = ActivityState(now: DateTime.now());
  ActivityState get state => _state;

  late final Timer _autoRefresh;
  bool _disposed = false;

  @override
  String? get message => _state.message;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    await _refresh();
  }

  void toggleAdding() {
    _emit(_state.copyWith(isAdding: !_state.isAdding));
  }

  /// True when [time] is still ahead today; the plan only takes blocks of the rest of the day.
  bool isLaterToday(LocalTime time) {
    final now = DateTime.now();
    return atTime(now, time).isAfter(now);
  }

  /// "Añadir al plan": one block today at [time].
  Future<void> addActivity({required String name, required LocalTime time, required int durationMinutes}) async {
    if (_state.isSaving) return;
    _emit(_state.copyWith(isSaving: true));
    final request = ScheduleReminderRequest(
      personUnderCareId: _careContext.careRecipientProfileId,
      type: ReminderType.physicalActivity,
      scheduledTime: atTime(DateTime.now(), time),
      title: name,
      durationMinutes: durationMinutes,
    );
    try {
      await scheduleReminder.execute(request);
      _emit(_state.copyWith(isSaving: false, isAdding: false, message: () => 'Actividad añadida al plan de hoy'));
      await _refresh();
    } catch (e) {
      _emit(_state.copyWith(
        isSaving: false,
        message: () => routineErrorMessage(e, 'No se pudo añadir la actividad'),
      ));
    }
  }

  /// "Registrar como completada": the platform accepts it once the block was issued to the wristband.
  Future<void> completeBlock(Reminder reminder) async {
    if (_state.busyReminderId != null) return;
    _emit(_state.copyWith(busyReminderId: () => reminder.id));
    try {
      await confirmReminder.execute(reminder.id);
      _emit(_state.copyWith(message: () => 'Actividad completada. Adherencia actualizada'));
      await _refresh();
    } catch (e) {
      _emit(_state.copyWith(message: () => routineErrorMessage(e, 'No se pudo registrar la actividad')));
    }
    _emit(_state.copyWith(busyReminderId: () => null));
  }

  @override
  void onMessageShown() {
    _emit(_state.copyWith(message: () => null));
  }

  Future<void> _refresh() async {
    final personUnderCareId = _careContext.careRecipientProfileId;
    final now = DateTime.now();
    final (startOfDay, startOfTomorrow) = todayBounds(now);
    final (weekStart, weekEnd) = lastWeek(now);

    final adherence = orNullOnError(
      getAdherence.execute(
        personUnderCareId: personUnderCareId,
        type: ReminderType.physicalActivity,
        from: weekStart,
        to: weekEnd,
      ),
    );
    try {
      final reminders = await getReminders.execute(
        personUnderCareId,
        from: startOfDay,
        to: startOfTomorrow,
        type: ReminderType.physicalActivity,
      );
      final weeklyAdherence = await adherence;
      _emit(_state.copyWith(
        isLoading: false,
        isLoaded: true,
        errorMessage: () => null,
        todayReminders: reminders,
        weeklyAdherence: () => weeklyAdherence,
        now: DateTime.now(),
      ));
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => routineErrorMessage(e, 'No se pudo cargar la actividad'),
      ));
    }
  }

  void _emit(ActivityState state) {
    // A request can finish after the user has left the screen
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _autoRefresh.cancel();
    super.dispose();
  }
}
