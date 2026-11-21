import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';

class AlertSettingsState {
  const new({
    this.isLoading = false,
    this.error,
    this.settings,
    this.configuredChannels = const [],
    this.contacts = const [],
    this.careRecipientName = '',
    this.isSavingSettings = false,
    this.savingChannel,
    this.actionError,
  });

  final bool isLoading;
  final ScreenError? error;
  final AlertSettings? settings;
  // Only what the member configured; see enabledChannels for what is actually in effect
  final List<AlertChannelSetting> configuredChannels;
  // Active contacts in escalation order, for the summary row
  final List<EmergencyContact> contacts;
  final String careRecipientName;
  final bool isSavingSettings;
  final NotificationChannel? savingChannel;
  final ScreenError? actionError;

  String get careRecipientFirstName => careRecipientName.split(' ').first;

  /// A member who never configured a channel receives in-app alerts, as the platform does.
  Set<NotificationChannel> get enabledChannels {
    if (configuredChannels.isEmpty) return {NotificationChannel.inApp};
    return configuredChannels.where((setting) => setting.enabled).map((setting) => setting.channel).toSet();
  }

  /// The platform refuses to turn off the last enabled channel.
  bool canDisable(NotificationChannel channel) {
    final enabled = enabledChannels;
    return !enabled.contains(channel) || enabled.length > 1;
  }

  EmergencyContact? get primaryContact => contacts.isEmpty ? null : contacts.first;

  // Nullable fields take a function, so copyWith can also set them back to null
  AlertSettingsState copyWith({
    bool? isLoading,
    ValueGetter<ScreenError?>? error,
    AlertSettings? settings,
    List<AlertChannelSetting>? configuredChannels,
    List<EmergencyContact>? contacts,
    bool? isSavingSettings,
    ValueGetter<NotificationChannel?>? savingChannel,
    ValueGetter<ScreenError?>? actionError,
  }) {
    return AlertSettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      settings: settings ?? this.settings,
      configuredChannels: configuredChannels ?? this.configuredChannels,
      contacts: contacts ?? this.contacts,
      careRecipientName: careRecipientName,
      isSavingSettings: isSavingSettings ?? this.isSavingSettings,
      savingChannel: savingChannel != null ? savingChannel() : this.savingChannel,
      actionError: actionError != null ? actionError() : this.actionError,
    );
  }
}
