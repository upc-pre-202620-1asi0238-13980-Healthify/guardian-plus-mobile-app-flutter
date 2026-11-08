import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_settings_dto.dart';

extension AlertSettingsDtoMapper on AlertSettingsDto {
  AlertSettings toDomain() {
    return AlertSettings(
      careRecipientProfileId: careRecipientProfileId,
      primaryAckTimeoutSec: primaryAckTimeoutSec,
      escalationEnabled: escalationEnabled,
      silentModeEnabled: silentModeEnabled,
      broadcastCriticalImmediately: broadcastCriticalImmediately,
    );
  }
}
