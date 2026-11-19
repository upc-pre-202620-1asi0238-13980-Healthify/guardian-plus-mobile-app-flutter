import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/application/location_use_cases.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/location_reading.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';

class SafeZonesState {
  final List<SafeZone> zones;
  final LocationReading? currentLocation;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const SafeZonesState({
    this.zones = const [],
    this.currentLocation,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  int get activeCount => zones.where((zone) => zone.isActive).length;

  SafeZonesState copyWith({
    List<SafeZone>? zones,
    LocationReading? Function()? currentLocation,
    bool? isLoading,
    bool? isSaving,
    String? Function()? errorMessage,
  }) {
    return SafeZonesState(
      zones: zones ?? this.zones,
      currentLocation: currentLocation != null ? currentLocation() : this.currentLocation,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

/// "Zonas seguras": list, create, edit, activate/deactivate and delete the geofences of the care recipient.
class SafeZonesViewModel extends ChangeNotifier {
  final GetSafeZonesUseCase getSafeZones;
  final GetCurrentLocationUseCase getCurrentLocation;
  final SaveSafeZoneUseCase saveSafeZone;
  final DeleteSafeZoneUseCase deleteSafeZone;
  final SetSafeZoneActiveUseCase setSafeZoneActive;
  final CareContextStore careContextStore;

  SafeZonesViewModel({
    required this.getSafeZones,
    required this.getCurrentLocation,
    required this.saveSafeZone,
    required this.deleteSafeZone,
    required this.setSafeZoneActive,
    required this.careContextStore,
  }) {
    load();
  }

  late final CareContext careContext = careContextStore.require();

  SafeZonesState _state = const SafeZonesState();
  SafeZonesState get state => _state;

  bool _disposed = false;

  String get _id => careContext.careRecipientProfileId;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    try {
      final zones = await getSafeZones.execute(_id);
      // The map still works without a reading: it only loses the marker
      final location = await getCurrentLocation.execute(_id).then<LocationReading?>((value) => value, onError: (_) => null);
      _emit(_state.copyWith(isLoading: false, zones: zones, currentLocation: () => location));
    } catch (error) {
      _emit(_state.copyWith(isLoading: false, errorMessage: () => _messageOf(error, 'No se pudieron cargar las zonas seguras')));
    }
  }

  /// Returns null when saved, or the message to show.
  Future<String?> save(SafeZoneDraft draft, {String? existingId}) {
    return _mutate(() => saveSafeZone.execute(_id, draft, existingId: existingId), 'No se pudo guardar la zona');
  }

  Future<String?> toggle(SafeZone zone, bool active) {
    return _mutate(() => setSafeZoneActive.execute(zone.id, active: active), 'No se pudo cambiar el estado de la zona');
  }

  Future<String?> remove(SafeZone zone) {
    return _mutate(() => deleteSafeZone.execute(zone.id), 'No se pudo eliminar la zona');
  }

  Future<String?> _mutate(Future<void> Function() action, String fallbackMessage) async {
    _emit(_state.copyWith(isSaving: true));
    try {
      await action();
      final zones = await getSafeZones.execute(_id);
      _emit(_state.copyWith(isSaving: false, zones: zones));
      return null;
    } catch (error) {
      _emit(_state.copyWith(isSaving: false));
      return _messageOf(error, fallbackMessage);
    }
  }

  String _messageOf(Object error, String fallback) {
    if (error is ApiException) return error.message;
    if (error is ArgumentError) return error.message.toString();
    return fallback;
  }

  void _emit(SafeZonesState state) {
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
