import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings_repository.dart';

/// The platform updates timeout, escalation and broadcast together, so every change sends the three (US11).
class UpdateAlertSettingsUseCase {
  final AlertSettingsRepository repository;

  const new({required this.repository});

  Future<AlertSettings> execute(AlertSettings settings) {
    return repository.updateAlertSettings(
      careRecipientProfileId: settings.careRecipientProfileId,
      primaryAckTimeoutSec: settings.primaryAckTimeoutSec,
      escalationEnabled: settings.escalationEnabled,
      broadcastCriticalImmediately: settings.broadcastCriticalImmediately,
    );
  }
}
