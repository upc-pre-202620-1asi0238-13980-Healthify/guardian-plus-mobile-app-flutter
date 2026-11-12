/// Same body as the platform's ConfigureInactivityDetectionResource.
class ConfigureInactivityDetectionRequestDto {
  final bool enabled;
  final int thresholdMinutes;

  const new({required this.enabled, required this.thresholdMinutes});

  Map<String, dynamic> toJson() {
    return {'enabled': enabled, 'thresholdMinutes': thresholdMinutes};
  }
}
