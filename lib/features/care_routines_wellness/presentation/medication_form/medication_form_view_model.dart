import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/schedule_reminder_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/recurrence_frequency.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/schedule_reminder_request.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/next_occurrence.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/medication_form/medication_form_state.dart';

/// "Nueva toma": schedules a medication reminder on the platform.
class MedicationFormViewModel extends ChangeNotifier implements RoutineMessageSource {
  final ScheduleReminderUseCase scheduleReminder;
  final CareContextStore careContextStore;

  new({required this.scheduleReminder, required this.careContextStore});

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  MedicationFormState _state = const MedicationFormState();
  MedicationFormState get state => _state;

  bool _disposed = false;

  @override
  String? get message => _state.errorMessage;

  /// Schedules the dose; a confirmed one is discounted from the stock of the medication with the same name,
  /// which the platform finds by itself.
  Future<void> save({
    required String name,
    required String dosage,
    required RecurrenceFrequency frequency,
    required Set<int> days,
    required LocalTime time,
    required String? instructions,
  }) async {
    if (_state.isSaving) return;
    _emit(_state.copyWith(isSaving: true, errorMessage: () => null));
    final request = ScheduleReminderRequest(
      personUnderCareId: _careContext.careRecipientProfileId,
      type: ReminderType.medication,
      scheduledTime: firstOccurrence(time: time, frequency: frequency, days: days, now: DateTime.now()),
      title: name,
      dosage: dosage,
      instructions: instructions,
      frequency: frequency,
      daysOfWeek: frequency == RecurrenceFrequency.weekly ? days : const {},
    );
    try {
      await scheduleReminder.execute(request);
      _emit(_state.copyWith(isSaving: false, savedTime: () => time));
    } catch (e) {
      _emit(_state.copyWith(
        isSaving: false,
        errorMessage: () => routineErrorMessage(e, 'No se pudo programar la toma'),
      ));
    }
  }

  @override
  void onMessageShown() {
    _emit(_state.copyWith(errorMessage: () => null));
  }

  void _emit(MedicationFormState state) {
    // A request can finish after the user has left the screen
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
