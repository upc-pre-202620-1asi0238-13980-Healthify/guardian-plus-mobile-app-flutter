import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/geo_distance.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/perimeter_monitor.dart';

import 'fakes.dart';

void main() {
  group('distanceInMeters', () {
    test('is zero for the same point and about 111 km per degree of latitude', () {
      expect(distanceInMeters(10, 20, 10, 20), 0);
      expect(distanceInMeters(10, 20, 11, 20), closeTo(111195, 200));
    });
  });

  group('PerimeterMonitor', () {
    final zone = testZone(lat: 10, lon: 20, radius: 100);
    // ~0.002 degrees of latitude is ~222 m: well outside a 100 m radius
    final outside = testReading(lat: 10.002, inside: false);
    final inside = testReading(inside: true, zoneName: 'Zona z1');

    test('does not alert on a single stray reading (sustained exit required)', () {
      final monitor = PerimeterMonitor(sustainedReadings: 2);
      expect(monitor.evaluate(outside, [zone]), isNull);
      expect(monitor.hasExited, isFalse);
    });

    test('alerts the exit after sustained readings, with the distance beyond the limit', () {
      final monitor = PerimeterMonitor(sustainedReadings: 2);
      monitor.evaluate(outside, [zone]);
      final event = monitor.evaluate(outside, [zone]);

      expect(event?.transition, PerimeterTransition.exited);
      expect(event?.zoneName, zone.name);
      expect(event?.distanceOutsideMeters, closeTo(122, 5));
      // already reported: no repeated alerts while it stays outside
      expect(monitor.evaluate(outside, [zone]), isNull);
    });

    test('a reading inside in between resets the streak', () {
      final monitor = PerimeterMonitor(sustainedReadings: 2);
      monitor.evaluate(outside, [zone]);
      monitor.evaluate(inside, [zone]);
      expect(monitor.evaluate(outside, [zone]), isNull);
    });

    test('notifies the automatic return once and restores regular vigilance', () {
      final monitor = PerimeterMonitor(sustainedReadings: 1);
      monitor.evaluate(outside, [zone]);

      final event = monitor.evaluate(inside, [zone]);
      expect(event?.transition, PerimeterTransition.reentered);
      expect(event?.zoneName, 'Zona z1');
      expect(monitor.hasExited, isFalse);
      expect(monitor.evaluate(inside, [zone]), isNull);
    });

    test('without active zones there is nothing to leave', () {
      final monitor = PerimeterMonitor(sustainedReadings: 1);
      expect(monitor.evaluate(outside, const []), isNull);
    });
  });
}
