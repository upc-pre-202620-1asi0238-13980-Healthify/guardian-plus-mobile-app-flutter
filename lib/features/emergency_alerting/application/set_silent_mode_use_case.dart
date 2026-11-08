import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings_repository.dart';

/// Silent mode (US22): the Care Circle gets non-critical alerts of this person without sound; critical ones
/// always sound.
class SetSilentModeUseCase {
  final AlertSettingsRepository repository;

  const new({required this.repository});

  Future<AlertSettings> execute({required String careRecipientProfileId, required bool enabled}) {
    return repository.setSilentMode(careRecipientProfileId: careRecipientProfileId, enabled: enabled);
  }
}
