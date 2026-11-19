import 'dart:async';

import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/mobility_repositories.dart';

class GetDeviceCapabilitiesUseCase {
  final CommunicationRepository repository;

  const GetDeviceCapabilitiesUseCase({required this.repository});

  Future<DeviceCapabilities?> execute(String fragileCitizenId) => repository.getDeviceCapabilities(fragileCitizenId);
}

/// How an attempt to call ended (US-23).
enum CallAttemptOutcome {
  /// Connected; [CallAttempt.session] says whether it is video or voice and if it was degraded.
  connected,

  /// The wearable cannot place calls at all: offer the phone numbers instead.
  unsupported,

  /// Nobody answered within the timeout; the attempt was logged in the caregiver's call log.
  unanswered,
}

class CallAttempt {
  final CallAttemptOutcome outcome;
  final CallSession? session;
  final CallType requestedType;

  const CallAttempt({required this.outcome, required this.requestedType, this.session});
}

/// Starts a call and applies the US-23 rules: video degrades to voice when the model has no camera (the platform
/// does it and reports it in the session), telemetry-only wearables get no call, and a call that is not answered
/// within [unansweredTimeout] is closed and logged as unanswered.
class StartCallUseCase {
  final CommunicationRepository repository;
  final Duration unansweredTimeout;

  const StartCallUseCase({required this.repository, required this.unansweredTimeout});

  Future<CallAttempt> execute(String fragileCitizenId, CallType requestedType) async {
    final CallSession session;
    try {
      session = await repository.startCall(fragileCitizenId, requestedType).timeout(unansweredTimeout);
    } on TimeoutException {
      await _logUnanswered(fragileCitizenId, requestedType);
      return CallAttempt(outcome: CallAttemptOutcome.unanswered, requestedType: requestedType);
    }

    switch (session.status) {
      case CallStatus.unsupported:
        return CallAttempt(outcome: CallAttemptOutcome.unsupported, requestedType: requestedType, session: session);
      case CallStatus.unanswered:
        // The platform closed it as unanswered by itself and keeps that record
        return CallAttempt(outcome: CallAttemptOutcome.unanswered, requestedType: requestedType, session: session);
      case CallStatus.active || CallStatus.ended:
        return CallAttempt(outcome: CallAttemptOutcome.connected, requestedType: requestedType, session: session);
    }
  }

  Future<void> _logUnanswered(String fragileCitizenId, CallType type) {
    return repository.logUnanswered(fragileCitizenId, type, unansweredTimeout.inSeconds);
  }
}

class EndCallUseCase {
  final CommunicationRepository repository;

  const EndCallUseCase({required this.repository});

  Future<CallSession> execute(String callId) => repository.endCall(callId);
}

class GetCallLogsUseCase {
  final CommunicationRepository repository;

  const GetCallLogsUseCase({required this.repository});

  Future<List<CallLogEntry>> execute(String fragileCitizenId) async {
    final logs = [...await repository.getCallLogs(fragileCitizenId)];
    logs.sort((a, b) => (b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0)));
    return logs;
  }
}

class SendHapticAlertUseCase {
  final CommunicationRepository repository;

  const SendHapticAlertUseCase({required this.repository});

  Future<void> execute(String fragileCitizenId, String reason) => repository.sendHapticAlert(fragileCitizenId, reason);
}
