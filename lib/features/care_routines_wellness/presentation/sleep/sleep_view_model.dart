import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_sleep_cycle_records_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/sleep/sleep_state.dart';

/// "Sueño": last night in detail and the nights of the past week.
class SleepViewModel extends ChangeNotifier {
  final GetSleepCycleRecordsUseCase getSleepCycleRecords;
  final CareContextStore careContextStore;

  new({required this.getSleepCycleRecords, required this.careContextStore}) {
    load();
  }

  static const _historyDays = 7;

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  SleepState _state = SleepState(now: DateTime.now());
  SleepState get state => _state;

  bool _disposed = false;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    final now = DateTime.now();
    try {
      final nights = await getSleepCycleRecords.execute(
        _careContext.careRecipientProfileId,
        from: now.subtract(const Duration(days: _historyDays)),
      );
      _emit(_state.copyWith(isLoading: false, isLoaded: true, nights: nights, now: now));
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => routineErrorMessage(e, 'No se pudo cargar el sueño'),
      ));
    }
  }

  void _emit(SleepState state) {
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
