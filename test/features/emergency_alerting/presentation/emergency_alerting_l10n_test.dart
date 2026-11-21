import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/components/escalation_notice.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/components/alert_detail_actions.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/components/day_header.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';
import 'package:guardian_plus_app/l10n/app_localizations.dart';

void main() {
  final es = lookupAppLocalizations(const Locale('es'));
  final en = lookupAppLocalizations(const Locale('en'));

  Widget app(Locale locale, Widget child) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('history days are named in the app language', (tester) async {
    final today = DateTime(2026, 9, 28);

    await tester.pumpWidget(app(const Locale('es'), DayHeader(day: DateTime(2026, 9, 26), today: today)));
    expect(find.text('SÁBADO 26 SEPT.'), findsOneWidget);

    await tester.pumpWidget(app(const Locale('en'), DayHeader(day: DateTime(2026, 9, 26), today: today)));
    expect(find.text('SATURDAY 26 SEP'), findsOneWidget);

    await tester.pumpWidget(app(const Locale('en'), DayHeader(day: DateTime(2026, 9, 27), today: today)));
    expect(find.text('YESTERDAY'), findsOneWidget);
  });

  testWidgets('the alert screens follow the app language', (tester) async {
    await tester.pumpWidget(
      app(
        const Locale('en'),
        Column(
          children: [
            const EscalationNotice(ackTimeoutSec: 60, onManageContacts: _noop),
            AlertDetailActions(
              actions: const AvailableActions(canAcknowledge: true, canCall: true),
              runningAction: null,
              careRecipientFirstName: 'Elena',
              onAcknowledge: _noop,
              onClaim: _noop,
              onComplete: _noop,
              onStabilize: _noop,
              onClose: _noop,
              onCall: _noop,
              onCallEmergency: _noop,
            ),
          ],
        ),
      ),
    );

    expect(
      find.text(
        'If nobody acknowledges a critical alert within 60 s, it will be sent automatically to your secondary '
        'contacts.',
      ),
      findsOneWidget,
    );
    expect(find.text('Acknowledge alert'), findsOneWidget);
    expect(find.text('Call Elena'), findsOneWidget);
  });

  test("a failure shows the platform's message, or what the screen was doing in the app language", () {
    final rejected = ScreenError.of(
      const ApiException('La alerta ya fue reconocida', statusCode: 409),
      FailedTask.acknowledge,
    );
    final unreadable = ScreenError.of(const FormatException('bad json'), FailedTask.loadAlerts);

    expect(rejected.message(en), 'La alerta ya fue reconocida');
    expect(unreadable.message(es), 'No se pudieron cargar las alertas');
    expect(unreadable.message(en), "Couldn't load the alerts");
  });
}

void _noop() {}
