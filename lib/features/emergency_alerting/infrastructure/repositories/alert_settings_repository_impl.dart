import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/mappers/alert_settings_mapper.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_settings_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/update_alert_settings_request_dto.dart';

class AlertSettingsRepositoryImpl implements AlertSettingsRepository {
  final AlertSettingsApi api;

  const new({required this.api});

  @override
  Future<AlertSettings> getAlertSettings(String careRecipientProfileId) async {
    final dto = await api.getAlertSettings(careRecipientProfileId);
    return dto.toDomain();
  }

  @override
  Future<AlertSettings> updateAlertSettings({
    required String careRecipientProfileId,
    required int primaryAckTimeoutSec,
    required bool escalationEnabled,
    required bool broadcastCriticalImmediately,
  }) async {
    final dto = await api.updateAlertSettings(
      careRecipientProfileId,
      UpdateAlertSettingsRequestDto(
        primaryAckTimeoutSec: primaryAckTimeoutSec,
        escalationEnabled: escalationEnabled,
        broadcastCriticalImmediately: broadcastCriticalImmediately,
      ),
    );
    return dto.toDomain();
  }

  // The platform models silent mode as a resource that is created (on) or deleted (off)
  @override
  Future<AlertSettings> setSilentMode({required String careRecipientProfileId, required bool enabled}) async {
    final dto = enabled
        ? await api.activateSilentMode(careRecipientProfileId)
        : await api.deactivateSilentMode(careRecipientProfileId);
    return dto.toDomain();
  }
}
