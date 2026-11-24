import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/application/communication_use_cases.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/call/call_page.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/call/call_view_model.dart';

import 'fakes.dart';

const _unansweredTimeout = Duration(milliseconds: 50);

CallViewModel _viewModel(FakeCommunicationRepository repository, {CallType type = CallType.video}) {
  return CallViewModel(
    getDeviceCapabilities: GetDeviceCapabilitiesUseCase(repository: repository),
    startCall: StartCallUseCase(repository: repository, unansweredTimeout: _unansweredTimeout),
    endCall: EndCallUseCase(repository: repository),
    getCallLogs: GetCallLogsUseCase(repository: repository),
    sendHapticAlert: SendHapticAlertUseCase(repository: repository),
    careContextStore: fakeCareContextStore(),
    now: () => DateTime.utc(2030, 1, 1, 15, 42),
    initialType: type,
  );
}

Future<void> _show(WidgetTester tester, CallViewModel viewModel) async {
  await tester.pumpWidget(MaterialApp(home: CallPage(viewModel: viewModel)));
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('video call: shows the live video session', (tester) async {
    final repository = FakeCommunicationRepository()
      ..capabilities = testCapabilities(CommunicationCapability.videoAndAudio)
      ..onStartCall = ((type) async => testSession(type: type));
    final viewModel = _viewModel(repository);

    await _show(tester, viewModel);

    expect(viewModel.state.phase, CallPhase.videoActive);
    expect(find.text('En videollamada'), findsOneWidget);
    expect(find.byTooltip('Finalizar llamada'), findsOneWidget);
    expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('audio-only wearable: informs the degradation and keeps a voice call', (tester) async {
    final repository = FakeCommunicationRepository()
      ..capabilities = testCapabilities(CommunicationCapability.audioOnly)
      ..onStartCall = ((_) async => testSession(type: CallType.voice, degraded: true, reason: 'Solo audio bidireccional'));
    final viewModel = _viewModel(repository);

    await _show(tester, viewModel);

    expect(viewModel.state.phase, CallPhase.voiceActive);
    expect(find.textContaining('Modelo sin cámara detectado'), findsOneWidget);
    expect(find.textContaining('Solo audio bidireccional'), findsOneWidget);
    expect(find.byIcon(Icons.videocam_outlined), findsNothing);
    expect(repository.startCalls, 1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('telemetry-only wearable: says it has no calls and offers the phone numbers', (tester) async {
    final repository = FakeCommunicationRepository()
      ..capabilities = testCapabilities(
        CommunicationCapability.telemetryOnly,
        citizenPhone: '111',
        caregiverPhone: '222',
      );
    final viewModel = _viewModel(repository);

    await _show(tester, viewModel);

    expect(viewModel.state.phase, CallPhase.telemetryOnly);
    expect(repository.startCalls, 0);
    expect(find.textContaining('no admite llamadas'), findsOneWidget);
    expect(find.text('Llamar a línea celular'), findsOneWidget);
    expect(find.text('111'), findsOneWidget);
    expect(find.text('Llamar a cuidador'), findsOneWidget);
    expect(find.text('222'), findsOneWidget);
  });

  testWidgets('unanswered after the timeout: logs it and offers buzz, retry and last location', (tester) async {
    final repository = FakeCommunicationRepository()
      ..capabilities = testCapabilities(CommunicationCapability.videoAndAudio)
      ..onStartCall = neverAnswers;
    final viewModel = _viewModel(repository);

    await tester.pumpWidget(MaterialApp(home: CallPage(viewModel: viewModel)));
    // Future.timeout uses a fake-async Timer inside testWidgets, so advance the virtual clock past the timeout
    await tester.pump(_unansweredTimeout + const Duration(milliseconds: 10));
    await tester.pump();
    await tester.pump();

    expect(viewModel.state.phase, CallPhase.unanswered);
    expect(repository.unansweredLogged.single.$1, CallType.video);
    expect(find.text('Llamada no atendida'), findsOneWidget);
    expect(find.text('Enviar alerta vibratoria (Zumbido)'), findsOneWidget);
    expect(find.text('Reintentar llamada'), findsOneWidget);
    expect(find.textContaining('Ver última ubicación'), findsOneWidget);

    await tester.tap(find.text('Enviar alerta vibratoria (Zumbido)'));
    await tester.pump();
    await tester.pump();
    expect(repository.hapticReasons, hasLength(1));
  });
}
