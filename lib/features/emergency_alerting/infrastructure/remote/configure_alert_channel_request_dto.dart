/// Turns a channel on or off; [deviceToken] is only sent for PUSH, to register this phone's token.
class ConfigureAlertChannelRequestDto {
  final bool enabled;
  final String? deviceToken;

  const new({required this.enabled, this.deviceToken});

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      if (deviceToken != null) 'deviceToken': deviceToken,
    };
  }
}
