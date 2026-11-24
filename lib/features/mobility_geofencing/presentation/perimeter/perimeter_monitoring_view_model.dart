import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/application/location_use_cases.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/location_reading.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/perimeter_monitor.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';

class PerimeterMonitoringState {
  final LocationReading? location;
  final MobilityStatus? status;
  final List<SafeZone> zones;

  /// Last perimeter alert: an exit stays until dismissed or the care recipient comes back.
  final PerimeterEvent? event;
  final bool eventDismissed;
  final bool isLoading;
  final String? errorMessage;

  const PerimeterMonitoringState({
    this.location,
    this.status,
    this.zones = const [],
    this.event,
    this.eventDismissed = false,
    this.isLoading = false,
    this.errorMessage,
  });

  List<SafeZone> get activeZones => zones.where((zone) => zone.isActive).toList();

  bool get hasExited => event?.transition == PerimeterTransition.exited && !eventDismissed;

  PerimeterMonitoringState copyWith({
    LocationReading? Function()? location,
    MobilityStatus? Function()? status,
    List<SafeZone>? zones,
    PerimeterEvent? Function()? event,
    bool? eventDismissed,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return PerimeterMonitoringState(
      location: location != null ? location() : this.location,
      status: status != null ? status() : this.status,
      zones: zones ?? this.zones,
      event: event != null ? event() : this.event,
      eventDismissed: eventDismissed ?? this.eventDismissed,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

/// "Monitoreo perimetral": polls the platform for the position and decides whether the care recipient left the
/// safe zones (sustained exit) or came back.
class PerimeterMonitoringViewModel extends ChangeNotifier {
  final GetCurrentLocationUseCase getCurrentLocation;
  final GetMobilityStatusUseCase getMobilityStatus;
  final GetSafeZonesUseCase getSafeZones;
  final CareContextStore careContextStore;
  final Duration refreshInterval;
  final PerimeterMonitor monitor;

  PerimeterMonitoringViewModel({
    required this.getCurrentLocation,
    required this.getMobilityStatus,
    required this.getSafeZones,
    required this.careContextStore,
    required this.refreshInterval,
    required this.monitor,
  }) {
    load();
    _timer = Timer.periodic(refreshInterval, (_) => _refresh());
  }

  late final CareContext careContext = careContextStore.require();

  PerimeterMonitoringState _state = const PerimeterMonitoringState();
  PerimeterMonitoringState get state => _state;

  Timer? _timer;
  bool _disposed = false;
  bool _fetching = false;

  String get _id => careContext.careRecipientProfileId;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    await _refresh();
  }

  Future<void> _refresh() async {
    if (_fetching || _disposed) return;
    _fetching = true;
    try {
      final zones = await getSafeZones.execute(_id);
      final location = await getCurrentLocation.execute(_id);
      final status = await getMobilityStatus.execute(_id);

      var next = _state.copyWith(isLoading: false, zones: zones, location: () => location, status: () => status, errorMessage: () => null);
      if (location != null) {
        final event = monitor.evaluate(location, zones.where((zone) => zone.isActive).toList());
        if (event != null) next = next.copyWith(event: () => event, eventDismissed: false);
      }
      _emit(next);
    } catch (error) {
      debugPrint('[Perimeter] refresh failed: $error');
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => error is ApiException ? error.message : 'No se pudo actualizar la ubicación: $error',
      ));
    } finally {
      _fetching = false;
    }
  }

  Future<void> refresh() => load();

  void dismissAlert() => _emit(_state.copyWith(eventDismissed: true));

  void _emit(PerimeterMonitoringState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
