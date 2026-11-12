import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/cancel_reminder_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_reminders_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/appointments/appointments_state.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_day.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';

/// "Citas médicas": the next appointment, the later ones and a way to schedule another.
class AppointmentsViewModel extends ChangeNotifier implements RoutineMessageSource {
  final GetRemindersUseCase getReminders;
  final CancelReminderUseCase cancelReminder;
  final CareContextStore careContextStore;

  new({required this.getReminders, required this.cancelReminder, required this.careContextStore}) {
    load();
  }

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  AppointmentsState _state = AppointmentsState(now: DateTime.now());
  AppointmentsState get state => _state;

  String get careRecipientFirstName => _careContext.careRecipientFirstName;

  bool _disposed = false;

  @override
  String? get message => _state.message;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    await _refresh();
  }

  /// Cancels the appointment and its reminders; for a recurring one, the whole series.
  Future<void> cancelAppointment(Reminder appointment) async {
    if (_state.cancellingId != null) return;
    _emit(_state.copyWith(cancellingId: () => appointment.id));
    try {
      await cancelReminder.execute(appointment.id);
      _emit(_state.copyWith(message: () => 'Cita cancelada y recordatorios eliminados'));
      await _refresh();
    } catch (e) {
      _emit(_state.copyWith(message: () => routineErrorMessage(e, 'No se pudo cancelar la cita')));
    }
    _emit(_state.copyWith(cancellingId: () => null));
  }

  /// An appointment scheduled on the form comes back as a message to confirm it, and changes the list.
  Future<void> onFormResult(String message) async {
    _emit(_state.copyWith(message: () => message));
    await _refresh();
  }

  @override
  void onMessageShown() {
    _emit(_state.copyWith(message: () => null));
  }

  Future<void> _refresh() async {
    // From the start of today, so an appointment that is about to start still shows
    final (startOfDay, _) = todayBounds(DateTime.now());
    try {
      final reminders = await getReminders.execute(
        _careContext.careRecipientProfileId,
        from: startOfDay,
        type: ReminderType.appointment,
      );
      _emit(_state.copyWith(
        isLoading: false,
        isLoaded: true,
        errorMessage: () => null,
        appointments: reminders.where((reminder) => reminder.status.isPending).toList()
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime)),
        now: DateTime.now(),
      ));
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => routineErrorMessage(e, 'No se pudieron cargar las citas'),
      ));
    }
  }

  void _emit(AppointmentsState state) {
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
