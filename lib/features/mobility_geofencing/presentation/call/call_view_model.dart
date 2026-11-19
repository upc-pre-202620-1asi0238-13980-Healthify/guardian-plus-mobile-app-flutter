import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/application/communication_use_cases.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';

enum CallPhase {
  /// Checking the wearable and placing the call.
  connecting,

  /// Video session established.
  videoActive,

  /// Voice session established (asked for voice, or degraded from video).
  voiceActive,

  /// The wearable cannot place calls: phone numbers are offered.
  telemetryOnly,

  /// 30 s without an answer; logged in the call log.
  unanswered,

  /// The call was ended by the caregiver.
  ended,

  failed,
}

class CallState {
  final CallPhase phase;
  final DeviceCapabilities? capabilities;
  final CallSession? session;
  final DateTime? unansweredAt;
  final List<CallLogEntry> logs;
  final String? notice;
  final String? errorMessage;
  final bool isBusy;

  const CallState({
    this.phase = CallPhase.connecting,
    this.capabilities,
    this.session,
    this.unansweredAt,
    this.logs = const [],
    this.notice,
    this.errorMessage,
    this.isBusy = false,
  });

  CallState copyWith({
    CallPhase? phase,
    DeviceCapabilities? Function()? capabilities,
    CallSession? Function()? session,
    DateTime? Function()? unansweredAt,
    List<CallLogEntry>? logs,
    String? Function()? notice,
    String? Function()? errorMessage,
    bool? isBusy,
  }) {
    return CallState(
      phase: phase ?? this.phase,
      capabilities: capabilities != null ? capabilities() : this.capabilities,
      session: session != null ? session() : this.session,
      unansweredAt: unansweredAt != null ? unansweredAt() : this.unansweredAt,
      logs: logs ?? this.logs,
      notice: notice != null ? notice() : this.notice,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}

/// Direct communication with the care recipient (US-23): video, degraded voice, telemetry-only and unanswered.
class CallViewModel extends ChangeNotifier {
  final GetDeviceCapabilitiesUseCase getDeviceCapabilities;
  final StartCallUseCase startCall;
  final EndCallUseCase endCall;
  final GetCallLogsUseCase getCallLogs;
  final SendHapticAlertUseCase sendHapticAlert;
  final CareContextStore careContextStore;
  final DateTime Function() now;

  CallViewModel({
    required this.getDeviceCapabilities,
    required this.startCall,
    required this.endCall,
    required this.getCallLogs,
    required this.sendHapticAlert,
    required this.careContextStore,
    required this.now,
    required CallType initialType,
  }) : _type = initialType {
    start();
  }

  late final CareContext careContext = careContextStore.require();

  CallType _type;
  CallType get requestedType => _type;

  CallState _state = const CallState();
  CallState get state => _state;

  bool _disposed = false;

  String get _id => careContext.careRecipientProfileId;

  /// Checks the wearable and places the call. Also used to retry.
  Future<void> start() async {
    _emit(CallState(logs: _state.logs, capabilities: _state.capabilities));
    try {
      final capabilities = await getDeviceCapabilities.execute(_id);
      if (capabilities == null) {
        _emit(_state.copyWith(phase: CallPhase.failed, errorMessage: () => 'No hay una pulsera vinculada'));
        return;
      }
      _emit(_state.copyWith(capabilities: () => capabilities));

      if (!capabilities.supportsVoice) {
        // Scenario 3: no bidirectional audio, so no call is placed
        _emit(_state.copyWith(phase: CallPhase.telemetryOnly));
        await _loadLogs();
        return;
      }

      final attempt = await startCall.execute(_id, _type);
      switch (attempt.outcome) {
        case CallAttemptOutcome.connected:
          final session = attempt.session!;
          final video = session.callType == CallType.video && !session.degradedToVoice;
          _emit(_state.copyWith(
            phase: video ? CallPhase.videoActive : CallPhase.voiceActive,
            session: () => session,
            notice: () => session.degradedToVoice ? (session.degradationReason ?? 'El modelo no admite vídeo') : null,
          ));
        case CallAttemptOutcome.unsupported:
          _emit(_state.copyWith(phase: CallPhase.telemetryOnly, session: () => attempt.session));
        case CallAttemptOutcome.unanswered:
          _emit(_state.copyWith(phase: CallPhase.unanswered, session: () => attempt.session, unansweredAt: () => now()));
      }
      await _loadLogs();
    } catch (error) {
      _emit(_state.copyWith(
        phase: CallPhase.failed,
        errorMessage: () => error is ApiException ? error.message : 'No se pudo establecer la llamada',
      ));
    }
  }

  Future<void> end() async {
    final session = _state.session;
    if (session == null) {
      _emit(_state.copyWith(phase: CallPhase.ended));
      return;
    }
    _emit(_state.copyWith(isBusy: true));
    try {
      final closed = await endCall.execute(session.callId);
      _emit(_state.copyWith(phase: CallPhase.ended, session: () => closed, isBusy: false));
    } catch (error) {
      _emit(_state.copyWith(isBusy: false, errorMessage: () => error is ApiException ? error.message : 'No se pudo finalizar la llamada'));
    }
  }

  /// Vibrating alert to the wearable; returns the message to show.
  Future<String> buzzWearable(String reason) async {
    final capabilities = _state.capabilities;
    if (capabilities != null && !capabilities.supportsHapticAlerts) {
      return 'La pulsera no admite alertas vibratorias';
    }
    _emit(_state.copyWith(isBusy: true));
    try {
      await sendHapticAlert.execute(_id, reason);
      return 'Alerta vibratoria enviada';
    } catch (error) {
      return error is ApiException ? error.message : 'No se pudo enviar la alerta vibratoria';
    } finally {
      _emit(_state.copyWith(isBusy: false));
    }
  }

  void retryAs(CallType type) {
    _type = type;
    start();
  }

  Future<void> _loadLogs() async {
    try {
      final logs = await getCallLogs.execute(_id);
      _emit(_state.copyWith(logs: logs));
    } catch (_) {
      // The log is a complement; the call state does not depend on it
    }
  }

  void _emit(CallState state) {
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
