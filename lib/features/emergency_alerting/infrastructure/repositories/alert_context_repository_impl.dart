import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_context.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_context_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/location/place_name_resolver.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/location_tracking_api.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/get_live_vital_signs_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_signs.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';

/// Reads the context of an alert from the bounded contexts that own it: the wristband's live readings from
/// Health Monitoring and the last known position from Mobility & Geofencing. Each part is shown when it can be
/// read; one that fails or does not exist yet is simply left out.
class AlertContextRepositoryImpl implements AlertContextRepository {
  final GetLiveVitalSignsUseCase getLiveVitalSigns;
  final LocationTrackingApi locationTrackingApi;
  final PlaceNameResolver placeNameResolver;

  const new({required this.getLiveVitalSigns, required this.locationTrackingApi, required this.placeNameResolver});

  static const _wristbandSources = {
    AlertSourceType.fallDetected,
    AlertSourceType.sosTriggered,
    AlertSourceType.vitalSignAnomaly,
  };

  // Where the person is matters when someone has to go there
  static const _locatedSources = {
    AlertSourceType.fallDetected,
    AlertSourceType.sosTriggered,
    AlertSourceType.safeZoneViolation,
    AlertSourceType.prolongedInactivity,
  };

  @override
  Future<AlertContext> getAlertContext(Alert alert) async {
    final careRecipientProfileId = alert.careRecipientProfileId;
    final (readings, location) = await (
      _wristbandSources.contains(alert.sourceType) ? _liveVitalSigns(careRecipientProfileId) : Future.value(null),
      _locatedSources.contains(alert.sourceType) ? _currentLocation(careRecipientProfileId) : Future.value(null),
    ).wait;
    // A reading older than the live window is the last known value, not what is happening now
    final live = readings?.vitalSigns.where((sign) => sign.liveSignal).toList() ?? const [];
    int? valueOf(VitalSignType type) => live.where((sign) => sign.type == type).firstOrNull?.value.round();
    return AlertContext(
      heartRateBpm: valueOf(VitalSignType.hr),
      oxygenSaturation: valueOf(VitalSignType.spo2),
      locationName: location?.name,
      locationUpdatedAt: location?.recordedAt,
    );
  }

  Future<LiveVitalSigns?> _liveVitalSigns(String careRecipientProfileId) async {
    try {
      return await getLiveVitalSigns.execute(careRecipientProfileId);
    } catch (_) {
      return null;
    }
  }

  // Mobility answers 404 until the wristband has sent a first position
  Future<({String name, DateTime? recordedAt})?> _currentLocation(String careRecipientProfileId) async {
    try {
      final dto = await locationTrackingApi.getCurrentLocation(careRecipientProfileId);
      final latitude = dto.latitude;
      final longitude = dto.longitude;
      if (latitude == null || longitude == null) return null;
      final name =
          await placeNameResolver.nameOf(latitude, longitude) ??
          '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
      return (name: name, recordedAt: dto.recordedAt == null ? null : DateTime.tryParse(dto.recordedAt!));
    } catch (_) {
      // A 404 or any other failure leaves the location out; the next read tries again
      return null;
    }
  }
}
