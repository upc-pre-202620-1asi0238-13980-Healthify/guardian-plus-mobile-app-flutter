/// One channel of a Care Circle member as the platform sends it (AlertChannelSettingResource).
class AlertChannelSettingDto {
  final String userId;
  final String channel;
  final bool enabled;
  final bool deviceTokenRegistered;

  const new({
    required this.userId,
    required this.channel,
    required this.enabled,
    required this.deviceTokenRegistered,
  });

  factory AlertChannelSettingDto.fromJson(Map<String, dynamic> json) {
    return AlertChannelSettingDto(
      userId: json['userId'],
      channel: json['channel'],
      enabled: json['enabled'],
      deviceTokenRegistered: json['deviceTokenRegistered'] ?? false,
    );
  }
}
