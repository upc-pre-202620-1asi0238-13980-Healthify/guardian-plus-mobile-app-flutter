import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/schedule_reminder_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/schedule_reminder_request.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/appointment_form/appointment_form_state.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';

/// "Nueva cita": schedules a medical appointment and its preventive notice.
class AppointmentFormViewModel extends ChangeNotifier implements RoutineMessageSource {
  final ScheduleReminderUseCase scheduleReminder;
  final CareContextStore careContextStore;

  new({required this.scheduleReminder, required this.careContextStore});

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  AppointmentFormState _state = const AppointmentFormState();
  AppointmentFormState get state => _state;

  String get careRecipientFirstName => _careContext.careRecipientFirstName;

  bool _disposed = false;

  @override
  String? get message => _state.errorMessage;

  Future<void> save({
    required String specialty,
    required DateTime dateTime,
    required String location,
    required int leadTimeMinutes,
  }) async {
    if (_state.isSaving) return;
    _emit(_state.copyWith(isSaving: true, errorMessage: () => null));
    final request = ScheduleReminderRequest(
      personUnderCareId: _careContext.careRecipientProfileId,
      type: ReminderType.appointment,
      scheduledTime: dateTime,
      title: specialty,
      location: location,
      leadTimeMinutes: leadTimeMinutes,
    );
    try {
      await scheduleReminder.execute(request);
      _emit(_state.copyWith(isSaving: false, saved: true));
    } catch (e) {
      _emit(_state.copyWith(
        isSaving: false,
        errorMessage: () => routineErrorMessage(e, 'No se pudo agendar la cita'),
      ));
    }
  }

  @override
  void onMessageShown() {
    _emit(_state.copyWith(errorMessage: () => null));
  }

  void _emit(AppointmentFormState state) {
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
