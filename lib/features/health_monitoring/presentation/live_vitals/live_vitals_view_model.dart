import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/core/text/initials.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/get_live_vital_signs_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/get_vital_sign_history_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/get_wearable_devices_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/device_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_reading.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/live_vitals_state.dart';

/// Latest readings of the care recipient, refreshed every few seconds. Shared by "Inicio" and "Salud › Ahora".
class LiveVitalsViewModel extends ChangeNotifier {
  final GetLiveVitalSignsUseCase getLiveVitalSigns;
  final GetWearableDevicesUseCase getWearableDevices;
  final GetVitalSignHistoryUseCase getVitalSignHistory;
  final CareContextStore careContextStore;

  new({
    required this.getLiveVitalSigns,
    required this.getWearableDevices,
    required this.getVitalSignHistory,
    required this.careContextStore,
  }) {
    load();
    _autoRefresh = Timer.periodic(_autoRefreshInterval, (_) {
      if (!_state.isLoading) _refresh();
    });
  }

  static const _autoRefreshInterval = Duration(seconds: 10);

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  late LiveVitalsState _state = LiveVitalsState(
    careRecipientFirstName: _careContext.careRecipientFirstName,
    now: DateTime.now(),
  );
  LiveVitalsState get state => _state;

  CareContext get careContext => _careContext;

  String get userInitials => initialsOf(_careContext.userFullName);

  late final Timer _autoRefresh;
  bool _disposed = false;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    await _refresh();
    await _loadToday();
  }

  Future<void> _refresh() async {
    final careRecipientId = _careContext.careRecipientProfileId;
    List<WearableDevice> devices;
    try {
      devices = await getWearableDevices.execute(careRecipientId);
    } catch (_) {
      devices = const [];
    }
    final hasWristband = devices.any((device) => device.deviceType == DeviceType.wristband);

    try {
      final vitals = await getLiveVitalSigns.execute(careRecipientId);
      _emit(_state
          .copyWith(
            isLoading: false,
            errorMessage: () => null,
            vitals: vitals,
            hasWristband: hasWristband,
            now: DateTime.now(),
          )
          .withReadings([
            for (final sign in vitals.vitalSigns)
              VitalSignReading(id: sign.id, type: sign.type, value: sign.value, measuredAt: sign.measuredAt),
          ]));
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        hasWristband: hasWristband,
        now: DateTime.now(),
        errorMessage: () => e is ApiException ? e.message : 'No se pudieron cargar los signos vitales',
      ));
    }
  }

  // Once per load: the sparkline and today's max and min start from the history, then grow with each refresh
  Future<void> _loadToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    try {
      // The platform filters by UTC date, so the next day is asked too and the state keeps the local one
      final readings = await getVitalSignHistory.execute(
        _careContext.careRecipientProfileId,
        from: today,
        to: today.add(const Duration(days: 1)),
      );
      _emit(_state.withReadings(readings));
    } catch (_) {
      // Without the history the sparkline starts from the live readings
    }
  }

  void _emit(LiveVitalsState state) {
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
