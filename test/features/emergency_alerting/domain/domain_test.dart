import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/phone_number.dart';

import '../fakes.dart';

void main() {
  group('PhoneNumber', () {
    test('accepts E.164 numbers', () {
      expect(PhoneNumber.isValid('+51987654321'), isTrue);
      expect(PhoneNumber.isValid('+12025550123'), isTrue);
    });

    test('rejects numbers without country code, with a leading zero or too short', () {
      expect(PhoneNumber.isValid('987654321'), isFalse);
      expect(PhoneNumber.isValid('+0987654321'), isFalse);
      expect(PhoneNumber.isValid('+51'), isFalse);
      expect(PhoneNumber.isValid('+51 987 654 321'), isFalse);
    });
  });

  test('activeInOrder leaves out removed contacts and puts the primary first', () {
    final contacts = [
      contact('c', priorityOrder: 3),
      contact('removed', priorityOrder: 1, active: false),
      contact('a', priorityOrder: 1),
      contact('b', priorityOrder: 2),
    ];

    expect(contacts.activeInOrder().map((contact) => contact.id), ['a', 'b', 'c']);
  });
}
