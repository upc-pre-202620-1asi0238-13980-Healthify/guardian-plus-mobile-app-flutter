import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting_repository.dart';

class GetAlertChannelSettingsUseCase {
  final AlertChannelSettingRepository repository;

  const new({required this.repository});

  Future<List<AlertChannelSetting>> execute(String userId) {
    return repository.getChannelSettings(userId);
  }
}
