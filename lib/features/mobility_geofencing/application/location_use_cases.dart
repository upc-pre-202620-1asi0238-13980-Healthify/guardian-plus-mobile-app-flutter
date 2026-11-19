import 'package:guardian_plus_app/features/mobility_geofencing/domain/location_reading.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/mobility_repositories.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';

class GetCurrentLocationUseCase {
  final LocationTrackingRepository repository;

  const GetCurrentLocationUseCase({required this.repository});

  Future<LocationReading?> execute(String fragileCitizenId) => repository.getCurrent(fragileCitizenId);
}

class GetLocationHistoryUseCase {
  final LocationTrackingRepository repository;

  const GetLocationHistoryUseCase({required this.repository});

  /// Newest first.
  Future<List<LocationReading>> execute(String fragileCitizenId) async {
    final readings = [...await repository.getHistory(fragileCitizenId)];
    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return readings;
  }
}

class GetMobilityStatusUseCase {
  final LocationTrackingRepository repository;

  const GetMobilityStatusUseCase({required this.repository});

  Future<MobilityStatus> execute(String fragileCitizenId) => repository.getStatus(fragileCitizenId);
}

class GetSafeZonesUseCase {
  final SafeZoneRepository repository;

  const GetSafeZonesUseCase({required this.repository});

  Future<List<SafeZone>> execute(String fragileCitizenId) => repository.getSafeZones(fragileCitizenId);
}

/// Why a zone draft is not acceptable, so the form can say it before calling the platform.
String? validateSafeZoneDraft(SafeZoneDraft draft) {
  if (draft.name.trim().isEmpty) return 'Escribe un nombre para la zona';
  if (draft.radiusMeters <= 0) return 'El radio debe ser mayor a 0 metros';
  if (draft.latitude < -90 || draft.latitude > 90 || draft.longitude < -180 || draft.longitude > 180) {
    return 'La ubicación de la zona no es válida';
  }
  return null;
}

class SaveSafeZoneUseCase {
  final SafeZoneRepository repository;

  const SaveSafeZoneUseCase({required this.repository});

  /// Creates the zone, or updates it when [existingId] is given.
  Future<SafeZone> execute(String fragileCitizenId, SafeZoneDraft draft, {String? existingId}) {
    final problem = validateSafeZoneDraft(draft);
    if (problem != null) throw ArgumentError(problem);
    final trimmed = SafeZoneDraft(
      name: draft.name.trim(),
      latitude: draft.latitude,
      longitude: draft.longitude,
      radiusMeters: draft.radiusMeters,
    );
    return existingId == null ? repository.create(fragileCitizenId, trimmed) : repository.update(existingId, trimmed);
  }
}

class DeleteSafeZoneUseCase {
  final SafeZoneRepository repository;

  const DeleteSafeZoneUseCase({required this.repository});

  Future<void> execute(String safeZoneId) => repository.delete(safeZoneId);
}

class SetSafeZoneActiveUseCase {
  final SafeZoneRepository repository;

  const SetSafeZoneActiveUseCase({required this.repository});

  Future<void> execute(String safeZoneId, {required bool active}) => repository.setActive(safeZoneId, active: active);
}
