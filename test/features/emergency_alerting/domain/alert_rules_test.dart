import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/response_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/escalation.dart';

import '../alert_fakes.dart';

void main() {
  group('escalationSecondsLeft', () {
    int? left(Alert a, {bool enabled = true}) =>
        a.escalationSecondsLeft(ackTimeoutSec: 60, escalationEnabled: enabled, now: testNow);

    test('counts down from the last dispatch', () {
      expect(left(alert('a', dispatchedAgo: const Duration(seconds: 18))), 42);
    });

    test('stops at zero once the timeout has passed', () {
      expect(left(alert('a', dispatchedAgo: const Duration(seconds: 90))), 0);
    });

    test('does not escalate medium alerts, acknowledged ones, broadcasts or with escalation off', () {
      const dispatched = Duration(seconds: 10);
      expect(left(alert('a', severity: Severity.medium, dispatchedAgo: dispatched)), isNull);
      expect(left(alert('a', status: AlertStatus.acknowledged, dispatchedAgo: dispatched)), isNull);
      expect(left(alert('a', level: RecipientLevel.broadcast, dispatchedAgo: dispatched)), isNull);
      expect(left(alert('a', dispatchedAgo: dispatched), enabled: false), isNull);
      expect(left(alert('a')), isNull, reason: 'without lastDispatchedAt there is nothing to count from');
    });
  });

  test('a fall has 20 s to be cancelled from the wristband', () {
    final waiting = alert('a', status: AlertStatus.pendingConfirmation, ago: const Duration(seconds: 7));
    expect(waiting.confirmationSecondsLeft(testNow), 13);
    expect(alert('a').confirmationSecondsLeft(testNow), isNull);
  });

  test('the active response is the one still on the way', () {
    final a = alert(
      'a',
      responses: [
        response('ana', status: ResponseStatus.completed),
        response('maria'),
      ],
    );
    expect(a.activeResponse?.responderUserId, 'maria');
  });

  test('the last page is the one whose index reaches the page count', () {
    expect(const AlertPage(alerts: [], page: 1, totalPages: 2, totalElements: 30).isLast, isTrue);
    expect(const AlertPage(alerts: [], page: 0, totalPages: 2, totalElements: 30).isLast, isFalse);
    expect(const AlertPage(alerts: [], page: 0, totalPages: 0, totalElements: 0).isLast, isTrue);
  });

  group('labels', () {
    test('the SOS title names the person under care', () {
      expect(AlertSourceType.sosTriggered.title('Elena'), 'Elena presionó el botón SOS');
    });

    test('relative times and durations read like the prototype', () {
      expect(relativeTime(testNow.subtract(const Duration(seconds: 3)), testNow), 'Ahora');
      expect(relativeTime(testNow.subtract(const Duration(seconds: 42)), testNow), 'Hace 42 s');
      expect(relativeTime(testNow.subtract(const Duration(minutes: 6)), testNow), 'Hace 6 min');
      expect(formatCountdown(42), '0:42');
      expect(formatCountdown(125), '2:05');
      expect(formatDuration(48), '48 s');
      expect(formatDuration(82), '1 min 22 s');
      expect(formatDuration(1080), '18 min');
      expect(formatDuration(3900), '1 h 05 min');
    });
  });
}
