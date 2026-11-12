import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/home/home_page.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/live_vitals_view_model.dart';

import 'fake_platform.dart';

void main() {
  late FakePlatform platform;

  setUp(() {
    platform = FakePlatform()..install();
  });

  tearDown(() => getIt.reset());

  Widget app({VoidCallback? onSeeVitals, VoidCallback? onLogout}) => MaterialApp(
    theme: GuardianTheme.light(),
    home: HomePage(
      viewModel: getIt<LiveVitalsViewModel>(),
      onSeeVitalsTap: onSeeVitals ?? () {},
      onAlertsTap: () {},
      onLogout: onLogout ?? () {},
    ),
  );

  testWidgets('the dashboard shows the live vitals and turns orange when one leaves its range', (tester) async {
    platform.wearables.add({
      'id': 'w1',
      'careRecipientProfileId': careRecipientId,
      'serialNumber': 'GP-ESP32-S3-0001',
      'deviceType': 'WRISTBAND',
      'linkedAt': '2026-10-01T10:00:00Z',
    });
    var seeVitals = 0;

    await tester.pumpWidget(app(onSeeVitals: () => seeVitals++));
    await tester.pumpAndSettle();

    expect(find.text('Todo bajo control'), findsOneWidget);
    expect(find.text('Elena está bien'), findsOneWidget);
    expect(find.text('ESTADO ACTUAL · EN LÍNEA'), findsOneWidget);
    expect(find.text('Pulsera conectada'), findsOneWidget);
    expect(find.text('78'), findsOneWidget);
    expect(find.text('118/76'), findsOneWidget);
    expect(find.text('36.6'), findsOneWidget);

    await tester.tap(find.text('Ver detalle'));
    expect(seeVitals, 1);

    // The next auto refresh brings a heart rate above its range
    platform.heartRate = 130;
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    expect(find.text('Revisa a Elena'), findsOneWidget);
    expect(find.text('Elena necesita atención'), findsOneWidget);
    expect(find.text('En observación'), findsOneWidget);
  });

  testWidgets('without a wristband the dashboard links one by its serial number', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Sin pulsera vinculada'), findsOneWidget);
    await tester.tap(find.text('Vincular'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vincular dispositivo'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa el número de serie del dispositivo'), findsOneWidget);

    await tester.enterText(find.byType(TextField), ' GP-ESP32-S3-0002 ');
    await tester.tap(find.text('Vincular dispositivo'));
    await tester.pumpAndSettle();

    expect(platform.wearables.single['serialNumber'], 'GP-ESP32-S3-0002');
    expect(platform.wearables.single['deviceType'], 'WRISTBAND');
    expect(find.text('Dispositivo vinculado'), findsOneWidget);
    expect(find.text('Pulsera conectada'), findsOneWidget);
  });

  testWidgets('the linked wristband opens its details', (tester) async {
    platform.wearables.add({
      'id': 'w1',
      'careRecipientProfileId': careRecipientId,
      'serialNumber': 'GP-ESP32-S3-0100',
      'deviceType': 'WRISTBAND',
      'linkedAt': '2026-10-06T07:00:36Z',
    });
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pulsera conectada'));
    await tester.pumpAndSettle();

    expect(find.text('Guardian+ Band'), findsNWidgets(2));
    expect(find.text('GP-ESP32-S3-0100'), findsOneWidget);
    expect(find.text('Vinculada a Elena Rojas'), findsOneWidget);

    // Unlinking is only announced for now: the device stays linked
    await tester.ensureVisible(find.text('Desvincular pulsera'));
    await tester.tap(find.text('Desvincular pulsera'));
    await tester.pumpAndSettle();
    expect(find.text('Próximamente'), findsOneWidget);
    expect(platform.wearables, hasLength(1));
  });

  testWidgets('the avatar signs out after confirming', (tester) async {
    var logouts = 0;
    await tester.pumpWidget(app(onLogout: () => logouts++));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cuenta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Dejarás de ver la información de Elena'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(logouts, 0);

    await tester.tap(find.byTooltip('Cuenta'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(logouts, 1);
  });

  testWidgets('a platform that cannot be reached offers to try again', (tester) async {
    platform.platformDown = true;
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Servicio no disponible'), findsOneWidget);

    platform.platformDown = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Elena está bien'), findsOneWidget);
  });
}
