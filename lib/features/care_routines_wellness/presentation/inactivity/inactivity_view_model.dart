import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/configure_inactivity_detection_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_activity_log_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_activity_monitor_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/inactivity/inactivity_state.dart';

/// "Inactividad": whether the person is moving, how inactivity is watched and the recent activity.
class InactivityViewModel extends ChangeNotifier implements RoutineMessageSource {
  final GetActivityMonitorUseCase getActivityMonitor;
  final GetActivityLogUseCase getActivityLog;
  final ConfigureInactivityDetectionUseCase configureInactivityDetection;
  final CareContextStore careContextStore;

  new({
    required this.getActivityMonitor,
    required this.getActivityLog,
    required this.configureInactivityDetection,
    required this.careContextStore,
  }) {
    load();
    // The counter of minutes without movement keeps changing with the wristband's samples
    _autoRefresh = Timer.periodic(_autoRefreshInterval, (_) {
      if (!_state.isLoading && !_state.isSaving) _refresh();
    });
  }

  static const _recentActivityLimit = 10;
  static const _autoRefreshInterval = Duration(seconds: 30);

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  InactivityState _state = InactivityState(now: DateTime.now());
  InactivityState get state => _state;

  String get careRecipientFirstName => _careContext.careRecipientFirstName;

  late final Timer _autoRefresh;
  bool _disposed = false;

  @override
  String? get message => _state.message;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    await _refresh();
  }

  void setDetectionEnabled(bool enabled) => _save(enabled, _state.thresholdMinutes);

  void setThreshold(int minutes) => _save(_state.detectionEnabled, minutes);

  @override
  void onMessageShown() {
    _emit(_state.copyWith(message: () => null));
  }

  // The control moves at once and goes back if the platform rejects the change
  Future<void> _save(bool enabled, int thresholdMinutes) async {
    final previous = _state;
    if (previous.isSaving) return;
    _emit(_state.copyWith(detectionEnabled: enabled, thresholdMinutes: thresholdMinutes, isSaving: true));
    try {
      final monitor = await configureInactivityDetection.execute(
        personUnderCareId: _careContext.careRecipientProfileId,
        enabled: enabled,
        thresholdMinutes: thresholdMinutes,
      );
      _emit(_state.withMonitor(monitor).copyWith(isSaving: false));
    } catch (e) {
      _emit(_state.copyWith(
        detectionEnabled: previous.detectionEnabled,
        thresholdMinutes: previous.thresholdMinutes,
        isSaving: false,
        message: () => routineErrorMessage(e, 'No se pudo guardar la detección de inactividad'),
      ));
    }
  }

  Future<void> _refresh() async {
    final personUnderCareId = _careContext.careRecipientProfileId;
    final log = orNullOnError(getActivityLog.execute(personUnderCareId: personUnderCareId, limit: _recentActivityLimit));
    try {
      final monitor = await getActivityMonitor.execute(personUnderCareId);
      final recentActivity = await log ?? const [];
      final updated = monitor != null ? _state.withMonitor(monitor) : _state;
      _emit(updated.copyWith(
        isLoading: false,
        isLoaded: true,
        errorMessage: () => null,
        recentActivity: recentActivity,
        now: DateTime.now(),
      ));
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => routineErrorMessage(e, 'No se pudo cargar la actividad'),
      ));
    }
  }

  void _emit(InactivityState state) {
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
