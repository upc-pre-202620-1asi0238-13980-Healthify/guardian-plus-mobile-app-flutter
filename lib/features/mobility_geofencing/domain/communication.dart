enum CommunicationCapability {
  videoAndAudio,
  audioOnly,
  telemetryOnly;

  static CommunicationCapability fromWire(String? value) {
    return switch (value) {
      'VIDEO_AND_AUDIO' => videoAndAudio,
      'AUDIO_ONLY' => audioOnly,
      _ => telemetryOnly,
    };
  }
}

enum CallType {
  video('VIDEO'),
  voice('VOICE');

  final String wire;
  const CallType(this.wire);

  static CallType fromWire(String? value) => value == 'VIDEO' ? video : voice;
}

enum CallStatus {
  active,
  ended,
  unanswered,
  unsupported;

  static CallStatus fromWire(String? value) {
    return switch (value) {
      'ACTIVE' => active,
      'ENDED' => ended,
      'UNANSWERED' => unanswered,
      _ => unsupported,
    };
  }
}

/// What the linked wearable can do for a direct communication (US-23).
class DeviceCapabilities {
  final String fragileCitizenId;
  final String? wristbandModel;
  final CommunicationCapability capability;
  final bool hasCamera;
  final bool hasScreen;
  final bool hasMicrophone;
  final bool hasSpeaker;
  final bool supportsHapticAlerts;
  final bool supportsTelemetry;
  final String? citizenPhone;
  final String? caregiverPhone;

  const DeviceCapabilities({
    required this.fragileCitizenId,
    required this.capability,
    required this.hasCamera,
    required this.hasScreen,
    required this.hasMicrophone,
    required this.hasSpeaker,
    required this.supportsHapticAlerts,
    required this.supportsTelemetry,
    this.wristbandModel,
    this.citizenPhone,
    this.caregiverPhone,
  });

  bool get supportsVideo => capability == CommunicationCapability.videoAndAudio;
  bool get supportsVoice => capability != CommunicationCapability.telemetryOnly;
}

class CallSession {
  final String callId;
  final String fragileCitizenId;
  final CallType callType;
  final CallStatus status;
  final bool degradedToVoice;
  final String? degradationReason;
  final DateTime? startedAt;
  final int? durationSeconds;
  final String? citizenPhone;
  final String? caregiverPhone;

  const CallSession({
    required this.callId,
    required this.fragileCitizenId,
    required this.callType,
    required this.status,
    required this.degradedToVoice,
    this.degradationReason,
    this.startedAt,
    this.durationSeconds,
    this.citizenPhone,
    this.caregiverPhone,
  });
}

class CallLogEntry {
  final String id;
  final String fragileCitizenId;
  final CallType callType;
  final CallStatus status;
  final int? durationSeconds;
  final DateTime? timestamp;
  final String? notes;

  const CallLogEntry({
    required this.id,
    required this.fragileCitizenId,
    required this.callType,
    required this.status,
    this.durationSeconds,
    this.timestamp,
    this.notes,
  });
}
