import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/delivery_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/response_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_state.dart';

import '../alert_fakes.dart';
import '../fakes.dart';

void main() {
  // María (contact a) is the signed-in member; Carlos (contact b) is the secondary contact
  final contacts = [
    contact('a', priorityOrder: 1).withName('María Rojas'),
    contact('b', priorityOrder: 2).withName('Carlos Rojas'),
  ];
  const me = 'user-a';

  AlertDetailState stateOf(Alert alert, {Incident? incident}) => AlertDetailState(
    alert: alert,
    incident: incident,
    contacts: contacts,
    currentUserId: me,
    careRecipientName: 'Elena Rojas',
    now: testNow,
  );

  test('only a member the alert was sent to can acknowledge it or say they are on the way', () {
    final sentToMe = stateOf(alert('x', deliveries: [delivery(me)]));
    final notSentToMe = stateOf(alert('x', deliveries: [delivery('user-b')]));

    expect(sentToMe.canAcknowledge, isTrue);
    expect(sentToMe.canClaim, isTrue);
    expect(notSentToMe.canAcknowledge, isFalse);
    expect(notSentToMe.canClaim, isFalse);
  });

  test('once someone is on the way nobody else is offered "Voy en camino", and only they see "Llegué"', () {
    final carlosGoing = alert(
      'x',
      status: AlertStatus.acknowledged,
      deliveries: [delivery(me), delivery('user-b')],
      responses: [response('user-b')],
    );
    final meGoing = alert('x', status: AlertStatus.acknowledged, deliveries: [delivery(me)], responses: [response(me)]);

    expect(stateOf(carlosGoing).canClaim, isFalse);
    expect(stateOf(carlosGoing).myActiveResponseId, isNull);
    expect(stateOf(meGoing).myActiveResponseId, 'response-$me');
  });

  test('the incident can be stabilized while in attention and closed until it is closed', () {
    final acknowledged = alert('x', status: AlertStatus.acknowledged);

    expect(stateOf(acknowledged, incident: incident('x')).canStabilize, isTrue);
    expect(stateOf(acknowledged, incident: incident('x')).canClose, isTrue);
    final stabilized = stateOf(acknowledged, incident: incident('x', status: IncidentStatus.stabilized));
    expect(stabilized.canStabilize, isFalse);
    expect(stabilized.canClose, isTrue);
    expect(stabilized.isCalm, isTrue);
    expect(stateOf(acknowledged).canClose, isFalse, reason: 'there is no incident before an acknowledgement');
  });

  test('each contact shows how far the alert got with them, primary first', () {
    final state = stateOf(
      alert(
        'x',
        status: AlertStatus.escalated,
        level: RecipientLevel.secondary,
        deliveries: [
          delivery(me, status: DeliveryStatus.failed),
          delivery(me, level: RecipientLevel.primary, status: DeliveryStatus.sent),
          delivery('user-b', level: RecipientLevel.secondary, status: DeliveryStatus.pending),
        ],
      ),
    );

    expect(state.escalationContacts.map((c) => (c.contact.displayName, c.status)), [
      ('María Rojas', ContactStatus.sent),
      ('Carlos Rojas', ContactStatus.sending),
    ]);
  });

  test('a contact the escalation never reached shows it was not needed', () {
    final state = stateOf(alert('x', status: AlertStatus.acknowledged, acknowledgedBy: me, deliveries: [delivery(me)]));

    expect(state.escalationContacts.map((c) => c.status), [ContactStatus.acknowledged, ContactStatus.notNeeded]);
  });

  test('the timeline lists what happened in order, with names, and the pending escalation last', () {
    final state = stateOf(
      alert(
        'x',
        ago: const Duration(seconds: 70),
        dispatchedAgo: const Duration(seconds: 50),
        deliveries: [delivery(me, sentAgo: const Duration(seconds: 50))],
      ),
    );

    final timeline = state.timeline;
    expect(timeline.map((e) => e.kind), [
      TimelineEventKind.detected,
      TimelineEventKind.sentTo,
      TimelineEventKind.nextEscalation,
    ]);
    expect(timeline[1].names, ['María Rojas']);
    expect(timeline.last.at, testNow.add(const Duration(seconds: 10)));
  });

  test('a finished alert shows the responder arriving and no pending escalation', () {
    final state = stateOf(
      alert(
        'x',
        status: AlertStatus.resolved,
        acknowledgedAfter: const Duration(seconds: 20),
        acknowledgedBy: me,
        dispatchedAgo: const Duration(seconds: 50),
        deliveries: [delivery(me)],
        responses: [response(me, status: ResponseStatus.completed)],
      ),
    );

    expect(state.isFinished, isTrue);
    expect(
      state.timeline.map((e) => e.kind),
      containsAllInOrder([
        TimelineEventKind.detected,
        TimelineEventKind.acknowledged,
        TimelineEventKind.onTheWay,
        TimelineEventKind.arrived,
      ]),
    );
    expect(state.timeline.map((e) => e.kind), isNot(contains(TimelineEventKind.nextEscalation)));
  });
}
