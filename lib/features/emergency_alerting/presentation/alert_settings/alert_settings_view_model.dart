import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/configure_alert_channel_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_channel_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/set_silent_mode_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/update_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';

/// How the alerts of the person under care escalate and sound (US11, US22), and how they reach this member (US12).
class AlertSettingsViewModel extends ChangeNotifier {
  final GetAlertSettingsUseCase getAlertSettings;
  final UpdateAlertSettingsUseCase updateAlertSettings;
  final SetSilentModeUseCase setSilentMode;
  final GetAlertChannelSettingsUseCase getAlertChannelSettings;
  final ConfigureAlertChannelUseCase configureAlertChannel;
  final GetEmergencyContactsUseCase getEmergencyContacts;
  final CareContextStore careContextStore;

  new({
    required this.getAlertSettings,
    required this.updateAlertSettings,
    required this.setSilentMode,
    required this.getAlertChannelSettings,
    required this.configureAlertChannel,
    required this.getEmergencyContacts,
    required this.careContextStore,
  }) {
    loadSettings();
  }

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  late AlertSettingsState _state = AlertSettingsState(careRecipientName: _careContext.careRecipientName);
  AlertSettingsState get state => _state;

  bool _disposed = false;

  Future<void> loadSettings() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));

    try {
      final channels = await getAlertChannelSettings.execute(_careContext.userAccountId);
      _emit(_state.copyWith(configuredChannels: channels));
    } catch (_) {
      // Without them the screen shows the platform's default (in-app only)
    }
    await refreshContacts();

    try {
      final settings = await getAlertSettings.execute(_careContext.careRecipientProfileId);
      _emit(_state.copyWith(isLoading: false, settings: settings));
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => errorMessageOf(e, 'No se pudo cargar la configuración'),
      ));
    }
  }

  /// The contacts row summarizes the list, which may have changed on the contacts screen.
  Future<void> refreshContacts() async {
    try {
      final contacts = await getEmergencyContacts.execute(_careContext.careRecipientProfileId);
      _emit(_state.copyWith(contacts: contacts.activeInOrder()));
    } catch (_) {
      // The summary keeps what it had
    }
  }

  void setEscalationEnabled(bool enabled) => _saveSettings((settings) => settings.copyWith(escalationEnabled: enabled));

  void setAckTimeout(int seconds) => _saveSettings((settings) => settings.copyWith(primaryAckTimeoutSec: seconds));

  void setBroadcastCriticalImmediately(bool enabled) =>
      _saveSettings((settings) => settings.copyWith(broadcastCriticalImmediately: enabled));

  Future<void> setSilentModeEnabled(bool enabled) async {
    final previous = _state.settings;
    if (previous == null || _state.isSavingSettings) return;
    _emit(_state.copyWith(settings: previous.copyWith(silentModeEnabled: enabled), isSavingSettings: true));
    try {
      final saved = await setSilentMode.execute(
        careRecipientProfileId: _careContext.careRecipientProfileId,
        enabled: enabled,
      );
      _emit(_state.copyWith(settings: saved, isSavingSettings: false));
    } catch (e) {
      _revertSettings(previous, e);
    }
  }

  Future<void> setChannelEnabled(NotificationChannel channel, bool enabled) async {
    if (_state.savingChannel != null) return;
    // Same rule as the platform, explained before sending a request that would be rejected
    if (!enabled && !_state.canDisable(channel)) {
      _emit(_state.copyWith(actionErrorMessage: () => 'Debe quedar al menos un canal activo para recibir las alertas'));
      return;
    }

    _emit(_state.copyWith(savingChannel: () => channel));
    try {
      final saved = await configureAlertChannel.execute(
        userId: _careContext.userAccountId,
        channel: channel,
        enabled: enabled,
      );
      final others = _state.configuredChannels.where((setting) => setting.channel != saved.channel);
      _emit(_state.copyWith(configuredChannels: [...others, saved], savingChannel: () => null));
    } catch (e) {
      _emit(_state.copyWith(
        savingChannel: () => null,
        actionErrorMessage: () => errorMessageOf(e, 'No se pudo cambiar el canal'),
      ));
    }
  }

  void onActionErrorShown() {
    _emit(_state.copyWith(actionErrorMessage: () => null));
  }

  /// The switch moves at once and goes back if the platform rejects the change.
  Future<void> _saveSettings(AlertSettings Function(AlertSettings) change) async {
    final previous = _state.settings;
    if (previous == null || _state.isSavingSettings) return;
    final updated = change(previous);
    _emit(_state.copyWith(settings: updated, isSavingSettings: true));
    try {
      final saved = await updateAlertSettings.execute(updated);
      _emit(_state.copyWith(settings: saved, isSavingSettings: false));
    } catch (e) {
      _revertSettings(previous, e);
    }
  }

  void _revertSettings(AlertSettings previous, Object error) {
    _emit(_state.copyWith(
      settings: previous,
      isSavingSettings: false,
      actionErrorMessage: () => errorMessageOf(error, 'No se pudo guardar la configuración'),
    ));
  }

  void _emit(AlertSettingsState state) {
    // A request can finish after the user has left the screen
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
