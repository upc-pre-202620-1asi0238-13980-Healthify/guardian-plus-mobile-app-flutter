import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';

const careRecipientId = 'elena';

CareContextStore careContextStore() {
  return CareContextStore()
    ..save(const CareContext(
      userAccountId: 'maria',
      userFullName: 'María Rojas',
      careRecipientProfileId: careRecipientId,
      careRecipientName: 'Elena Rojas',
    ));
}

EmergencyContact contact(String id, {required int priorityOrder, bool active = true, String? phoneNumber}) {
  return EmergencyContact(
    id: id,
    careRecipientProfileId: careRecipientId,
    userId: 'user-$id',
    displayName: 'Contacto $id',
    relationship: 'Hija',
    phoneNumber: phoneNumber ?? '+5198765430$priorityOrder',
    priorityOrder: priorityOrder,
    active: active,
  );
}

extension ContactNaming on EmergencyContact {
  EmergencyContact withName(String name) {
    return EmergencyContact(
      id: id,
      careRecipientProfileId: careRecipientProfileId,
      userId: userId,
      displayName: name,
      relationship: relationship,
      phoneNumber: phoneNumber,
      priorityOrder: priorityOrder,
      active: active,
    );
  }
}

/// Keeps the contacts in memory and follows the platform's rules (at least one contact, renumbered priorities).
class FakeEmergencyContactRepository implements EmergencyContactRepository {
  List<EmergencyContact> contacts;
  ApiException? failure;
  ApiException? reorderFailure;
  final List<List<String>> reorders = [];

  new(this.contacts);

  @override
  Future<List<EmergencyContact>> getEmergencyContacts(String careRecipientProfileId) async {
    if (failure != null) throw failure!;
    return contacts;
  }

  @override
  Future<EmergencyContact> addEmergencyContact({
    required String careRecipientProfileId,
    required String userId,
    required String displayName,
    required String relationship,
    required String phoneNumber,
  }) async {
    if (failure != null) throw failure!;
    final added = EmergencyContact(
      id: 'new-${contacts.length}',
      careRecipientProfileId: careRecipientProfileId,
      userId: userId,
      displayName: displayName,
      relationship: relationship,
      phoneNumber: phoneNumber,
      priorityOrder: contacts.length + 1,
      active: true,
    );
    contacts = [...contacts, added];
    return added;
  }

  @override
  Future<EmergencyContact> removeEmergencyContact(String emergencyContactId) async {
    if (failure != null) throw failure!;
    final removed = contacts.firstWhere((contact) => contact.id == emergencyContactId);
    contacts = _renumber(contacts.where((contact) => contact.id != emergencyContactId).toList());
    return removed;
  }

  @override
  Future<List<EmergencyContact>> reorderEmergencyContacts({
    required String careRecipientProfileId,
    required List<String> orderedIds,
  }) async {
    reorders.add(orderedIds);
    if (reorderFailure != null) throw reorderFailure!;
    contacts = _renumber([for (final id in orderedIds) contacts.firstWhere((contact) => contact.id == id)]);
    return contacts;
  }

  List<EmergencyContact> _renumber(List<EmergencyContact> ordered) {
    return [
      for (final (index, contact) in ordered.indexed)
        EmergencyContact(
          id: contact.id,
          careRecipientProfileId: contact.careRecipientProfileId,
          userId: contact.userId,
          displayName: contact.displayName,
          relationship: contact.relationship,
          phoneNumber: contact.phoneNumber,
          priorityOrder: index + 1,
          active: contact.active,
        ),
    ];
  }
}

class FakeAlertSettingsRepository implements AlertSettingsRepository {
  AlertSettings settings;
  ApiException? failure;
  ApiException? saveFailure;

  new({
    this.settings = const AlertSettings(
      careRecipientProfileId: careRecipientId,
      primaryAckTimeoutSec: 90,
      escalationEnabled: true,
      silentModeEnabled: false,
      broadcastCriticalImmediately: true,
    ),
  });

  @override
  Future<AlertSettings> getAlertSettings(String careRecipientProfileId) async {
    if (failure != null) throw failure!;
    return settings;
  }

  @override
  Future<AlertSettings> updateAlertSettings({
    required String careRecipientProfileId,
    required int primaryAckTimeoutSec,
    required bool escalationEnabled,
    required bool broadcastCriticalImmediately,
  }) async {
    if (saveFailure != null) throw saveFailure!;
    return settings = settings.copyWith(
      primaryAckTimeoutSec: primaryAckTimeoutSec,
      escalationEnabled: escalationEnabled,
      broadcastCriticalImmediately: broadcastCriticalImmediately,
    );
  }

  @override
  Future<AlertSettings> setSilentMode({required String careRecipientProfileId, required bool enabled}) async {
    if (saveFailure != null) throw saveFailure!;
    return settings = settings.copyWith(silentModeEnabled: enabled);
  }
}

class FakeAlertChannelSettingRepository implements AlertChannelSettingRepository {
  List<AlertChannelSetting> channels;
  final List<(NotificationChannel, bool)> configured = [];

  new([this.channels = const []]);

  @override
  Future<List<AlertChannelSetting>> getChannelSettings(String userId) async => channels;

  @override
  Future<AlertChannelSetting> configureChannel({
    required String userId,
    required NotificationChannel channel,
    required bool enabled,
  }) async {
    configured.add((channel, enabled));
    final saved = AlertChannelSetting(userId: userId, channel: channel, enabled: enabled, deviceTokenRegistered: false);
    channels = [...channels.where((setting) => setting.channel != channel), saved];
    return saved;
  }
}
