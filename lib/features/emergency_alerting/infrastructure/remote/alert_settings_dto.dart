/// The alert settings of a person under care as the platform sends them (AlertSettingsResource).
class AlertSettingsDto {
  final String careRecipientProfileId;
  final int primaryAckTimeoutSec;
  final bool escalationEnabled;
  final bool silentModeEnabled;
  final bool broadcastCriticalImmediately;

  const new({
    required this.careRecipientProfileId,
    required this.primaryAckTimeoutSec,
    required this.escalationEnabled,
    required this.silentModeEnabled,
    required this.broadcastCriticalImmediately,
  });

  factory AlertSettingsDto.fromJson(Map<String, dynamic> json) {
    return AlertSettingsDto(
      careRecipientProfileId: json['careRecipientProfileId'],
      primaryAckTimeoutSec: json['primaryAckTimeoutSec'],
      escalationEnabled: json['escalationEnabled'],
      silentModeEnabled: json['silentModeEnabled'],
      broadcastCriticalImmediately: json['broadcastCriticalImmediately'],
    );
  }
}
