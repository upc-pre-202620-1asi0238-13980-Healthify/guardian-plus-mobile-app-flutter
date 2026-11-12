import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/confirm_reminder_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_adherence_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_reminders_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/mark_reminder_as_missed_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_day.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/medication/medication_state.dart';

/// "Medicación": today's doses, the ones waiting for review and the adherence of the week.
class MedicationViewModel extends ChangeNotifier implements RoutineMessageSource {
  final GetRemindersUseCase getReminders;
  final GetAdherenceUseCase getAdherence;
  final ConfirmReminderUseCase confirmReminder;
  final MarkReminderAsMissedUseCase markReminderAsMissed;
  final CareContextStore careContextStore;

  new({
    required this.getReminders,
    required this.getAdherence,
    required this.confirmReminder,
    required this.markReminderAsMissed,
    required this.careContextStore,
  }) {
    load();
    // Doses are issued and confirmed on the wristband, so the day is refreshed periodically
    _autoRefresh = Timer.periodic(_autoRefreshInterval, (_) {
      if (!_state.isLoading && _state.busyReminderId == null) _refresh();
    });
  }

  static const _autoRefreshInterval = Duration(seconds: 30);

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  MedicationState _state = MedicationState(now: DateTime.now());
  MedicationState get state => _state;

  String get careRecipientFirstName => _careContext.careRecipientFirstName;

  late final Timer _autoRefresh;
  bool _disposed = false;

  @override
  String? get message => _state.message;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    await _refresh();
  }

  /// "Confirmar toma": the platform only accepts it once the dose was issued to the wristband.
  Future<void> confirmDose(Reminder reminder) {
    return _runOnDose(reminder, () async {
      await confirmReminder.execute(reminder.id);
      return 'Dosis registrada como administrada';
    });
  }

  /// "Revisar": closes a dose the person never confirmed; nothing is discounted from the stock.
  Future<void> markDoseAsMissed(Reminder reminder) {
    return _runOnDose(reminder, () async {
      await markReminderAsMissed.execute(reminder.id);
      return 'Omisión revisada';
    });
  }

  /// A dose scheduled on the form comes back as a message to confirm it, and changes the day.
  Future<void> onFormResult(String message) async {
    _emit(_state.copyWith(message: () => message));
    await _refresh();
  }

  @override
  void onMessageShown() {
    _emit(_state.copyWith(message: () => null));
  }

  Future<void> _runOnDose(Reminder reminder, Future<String> Function() action) async {
    if (_state.busyReminderId != null) return;
    _emit(_state.copyWith(busyReminderId: () => reminder.id));
    try {
      final message = await action();
      _emit(_state.copyWith(message: () => message));
      await _refresh();
    } catch (e) {
      _emit(_state.copyWith(message: () => routineErrorMessage(e, 'No se pudo actualizar la toma')));
    }
    _emit(_state.copyWith(busyReminderId: () => null));
  }

  Future<void> _refresh() async {
    final personUnderCareId = _careContext.careRecipientProfileId;
    final now = DateTime.now();
    final (startOfDay, startOfTomorrow) = todayBounds(now);
    final (weekStart, weekEnd) = lastWeek(now);

    final adherence = orNullOnError(
      getAdherence.execute(
        personUnderCareId: personUnderCareId,
        type: ReminderType.medication,
        from: weekStart,
        to: weekEnd,
      ),
    );
    try {
      final reminders = await getReminders.execute(
        personUnderCareId,
        from: startOfDay,
        to: startOfTomorrow,
        type: ReminderType.medication,
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
        errorMessage: () => routineErrorMessage(e, 'No se pudo cargar la medicación'),
      ));
    }
  }

  void _emit(MedicationState state) {
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
