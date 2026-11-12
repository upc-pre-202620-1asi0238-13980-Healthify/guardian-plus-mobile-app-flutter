import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/health/health_page.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/live_vitals_view_model.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/vital_history/vital_history_view_model.dart';

import 'fake_platform.dart';

void main() {
  late FakePlatform platform;

  setUp(() {
    platform = FakePlatform()..install();
  });

  tearDown(() => getIt.reset());

  Future<void> openHealth(WidgetTester tester) async {
    // Tall enough for the whole "Ahora" grid
    tester.view.physicalSize = const Size(1080, 2600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: GuardianTheme.light(),
      home: HealthPage(
        liveVitalsViewModel: getIt<LiveVitalsViewModel>(),
        vitalHistoryViewModel: getIt<VitalHistoryViewModel>(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('"Ahora" shows every vital sign and the filter narrows them down', (tester) async {
    platform.systolic = 150;
    await openHealth(tester);

    expect(find.text('Elena Rojas · En línea'), findsOneWidget);
    expect(find.text('FRECUENCIA CARDÍACA'), findsOneWidget);
    expect(find.text('PRESIÓN ARTERIAL'), findsOneWidget);
    expect(find.text('SATURACIÓN O₂'), findsOneWidget);
    expect(find.text('150/76'), findsOneWidget);

    await tester.tap(find.text('Todos los signos vitales'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'observacion');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'En observación'));
    await tester.pump();
    await tester.tap(find.text('Aplicar · 1'));
    await tester.pumpAndSettle();

    // Only the blood pressure is out of its range
    expect(find.text('PRESIÓN ARTERIAL'), findsOneWidget);
    expect(find.text('FRECUENCIA CARDÍACA'), findsNothing);
    expect(find.text('SATURACIÓN O₂'), findsNothing);
  });

  testWidgets('"Historial" averages the week and lists the latest readings with their state', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 9);
    platform
      ..addReading('HR', 70, today.subtract(const Duration(days: 2)))
      ..addReading('HR', 80, today.subtract(const Duration(days: 1)))
      ..addReading('BP_SYS', 146, today)
      ..addReading('BP_DIA', 80, today);
    await openHealth(tester);

    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();

    expect(find.text('PROMEDIO SEMANAL'), findsOneWidget);
    expect(find.text('75.0'), findsOneWidget);
    expect(find.text('Hoy · 09:00'), findsOneWidget);
    expect(find.text('146/80 mmHg'), findsOneWidget);
    expect(find.text('En observación'), findsOneWidget);

    await tester.tap(find.text('Presión'));
    await tester.pumpAndSettle();
    expect(find.text('146.0'), findsOneWidget);

    // A month goes back to the platform for more days
    final historyRequests = platform.requests.where((request) => request.url.path.contains('history')).length;
    await tester.tap(find.text('Todos los signos vitales'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Mes'));
    await tester.tap(find.text('Mes'));
    await tester.pump();
    await tester.tap(find.text('Aplicar · 1'));
    await tester.pumpAndSettle();

    expect(find.text('PROMEDIO MENSUAL'), findsOneWidget);
    expect(platform.requests.where((request) => request.url.path.contains('history')).length, historyRequests + 1);
  });
}
