import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/configure_hydration_plan_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_hydration_plan_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/hydration/hydration_state.dart';

/// "Hidratación": today's glasses against the goal and the plan of periodic reminders.
class HydrationViewModel extends ChangeNotifier implements RoutineMessageSource {
  final GetHydrationPlanUseCase getHydrationPlan;
  final ConfigureHydrationPlanUseCase configureHydrationPlan;
  final CareContextStore careContextStore;

  new({required this.getHydrationPlan, required this.configureHydrationPlan, required this.careContextStore}) {
    load();
  }

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  HydrationState _state = const HydrationState();
  HydrationState get state => _state;

  bool _disposed = false;

  @override
  String? get message => _state.message;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    try {
      final plan = await getHydrationPlan.execute(_careContext.careRecipientProfileId);
      _emit(_state.copyWith(
        isLoading: false,
        isLoaded: true,
        plan: () => plan,
        settings: plan != null ? HydrationSettings.of(plan) : HydrationSettings.defaults,
      ));
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => routineErrorMessage(e, 'No se pudo cargar la hidratación'),
      ));
    }
  }

  void setActive(bool active) => _save((settings) => settings.copyWith(active: active));

  void setDailyGoal(int glasses) => _save((settings) => settings.copyWith(dailyGoalGlasses: glasses));

  void setInterval(int hours) => _save((settings) => settings.copyWith(intervalHours: hours));

  void setRespectSleepWindow(bool respect) => _save((settings) => settings.copyWith(respectSleepWindow: respect));

  @override
  void onMessageShown() {
    _emit(_state.copyWith(message: () => null));
  }

  /// The platform replaces the whole plan on every change, so the four settings are always sent.
  /// The control moves at once and goes back if the platform rejects the change.
  Future<void> _save(HydrationSettings Function(HydrationSettings settings) change) async {
    if (_state.isSaving) return;
    final previous = _state.settings;
    final updated = change(previous);
    _emit(_state.copyWith(settings: updated, isSaving: true));
    try {
      final plan = await configureHydrationPlan.execute(
        personUnderCareId: _careContext.careRecipientProfileId,
        active: updated.active,
        dailyGoalGlasses: updated.dailyGoalGlasses,
        intervalHours: updated.intervalHours,
        respectSleepWindow: updated.respectSleepWindow,
      );
      _emit(_state.copyWith(plan: () => plan, settings: HydrationSettings.of(plan), isSaving: false));
    } catch (e) {
      _emit(_state.copyWith(
        settings: previous,
        isSaving: false,
        message: () => routineErrorMessage(e, 'No se pudo guardar el plan de hidratación'),
      ));
    }
  }

  void _emit(HydrationState state) {
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
