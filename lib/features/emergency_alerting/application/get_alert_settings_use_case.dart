import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings_repository.dart';

class GetAlertSettingsUseCase {
  final AlertSettingsRepository repository;

  const new({required this.repository});

  Future<AlertSettings> execute(String careRecipientProfileId) {
    return repository.getAlertSettings(careRecipientProfileId);
  }
}
