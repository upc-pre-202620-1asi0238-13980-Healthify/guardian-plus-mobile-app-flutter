import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/configure_alert_channel_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_channel_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/set_silent_mode_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/update_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_view_model.dart';

import '../fakes.dart';

void main() {
  late FakeAlertSettingsRepository settings;
  late FakeAlertChannelSettingRepository channels;
  late FakeEmergencyContactRepository contacts;

  AlertSettingsViewModel createViewModel() {
    return AlertSettingsViewModel(
      getAlertSettings: GetAlertSettingsUseCase(repository: settings),
      updateAlertSettings: UpdateAlertSettingsUseCase(repository: settings),
      setSilentMode: SetSilentModeUseCase(repository: settings),
      getAlertChannelSettings: GetAlertChannelSettingsUseCase(repository: channels),
      configureAlertChannel: ConfigureAlertChannelUseCase(repository: channels),
      getEmergencyContacts: GetEmergencyContactsUseCase(repository: contacts),
      careContextStore: careContextStore(),
    );
  }

  setUp(() {
    settings = FakeAlertSettingsRepository();
    channels = FakeAlertChannelSettingRepository();
    contacts = FakeEmergencyContactRepository([contact('b', priorityOrder: 2), contact('a', priorityOrder: 1)]);
  });

  test('loads the settings, the contacts summary and the default channel', () async {
    final viewModel = createViewModel();
    await pumpEventQueue();

    expect(viewModel.state.settings!.primaryAckTimeoutSec, 90);
    expect(viewModel.state.primaryContact!.id, 'a');
    // A member who never configured a channel receives in-app alerts
    expect(viewModel.state.enabledChannels, {NotificationChannel.inApp});
  });

  test('shows why the settings could not be loaded', () async {
    settings.failure = const ApiException('Configuración no encontrada');
    final viewModel = createViewModel();
    await pumpEventQueue();

    expect(viewModel.state.settings, isNull);
    expect(viewModel.state.errorMessage, 'Configuración no encontrada');
  });

  test('a new timeout is saved together with the rest of the escalation settings', () async {
    final viewModel = createViewModel();
    await pumpEventQueue();

    viewModel.setAckTimeout(180);
    // The selection shows at once, before the platform answers
    expect(viewModel.state.settings!.primaryAckTimeoutSec, 180);
    await pumpEventQueue();

    expect(settings.settings.primaryAckTimeoutSec, 180);
    expect(settings.settings.escalationEnabled, isTrue);
    expect(viewModel.state.isSavingSettings, isFalse);
  });

  test('a rejected change puts the switch back and says why', () async {
    final viewModel = createViewModel();
    await pumpEventQueue();
    settings.saveFailure = const ApiException('No autorizado');

    await viewModel.setSilentModeEnabled(true);

    expect(viewModel.state.settings!.silentModeEnabled, isFalse);
    expect(viewModel.state.actionErrorMessage, 'No autorizado');
  });

  test('the last enabled channel cannot be turned off, and nothing is sent', () async {
    final viewModel = createViewModel();
    await pumpEventQueue();

    await viewModel.setChannelEnabled(NotificationChannel.inApp, false);

    expect(channels.configured, isEmpty);
    expect(viewModel.state.actionErrorMessage, 'Debe quedar al menos un canal activo para recibir las alertas');
  });

  test('turning a channel on adds it to the ones in effect', () async {
    channels.channels = [
      const AlertChannelSetting(
        userId: 'maria',
        channel: NotificationChannel.inApp,
        enabled: true,
        deviceTokenRegistered: false,
      ),
    ];
    final viewModel = createViewModel();
    await pumpEventQueue();

    await viewModel.setChannelEnabled(NotificationChannel.sms, true);

    expect(viewModel.state.enabledChannels, {NotificationChannel.inApp, NotificationChannel.sms});
    expect(viewModel.state.canDisable(NotificationChannel.inApp), isTrue);
    expect(viewModel.state.savingChannel, isNull);
  });
}
