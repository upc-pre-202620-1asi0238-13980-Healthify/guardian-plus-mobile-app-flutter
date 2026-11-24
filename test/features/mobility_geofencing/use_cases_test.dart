import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/application/communication_use_cases.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/application/location_use_cases.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/mobility_geofencing_dependencies.dart';

import 'fakes.dart';

void main() {
  group('StartCallUseCase', () {
    late FakeCommunicationRepository repository;
    late StartCallUseCase useCase;

    setUp(() {
      repository = FakeCommunicationRepository();
      useCase = StartCallUseCase(repository: repository, unansweredTimeout: const Duration(milliseconds: 50));
    });

    test('video session: connected as video', () async {
      repository.onStartCall = (type) async => testSession(type: type);
      final attempt = await useCase.execute('citizen-test', CallType.video);

      expect(attempt.outcome, CallAttemptOutcome.connected);
      expect(attempt.session?.callType, CallType.video);
      expect(attempt.session?.degradedToVoice, isFalse);
    });

    test('degradation to voice is passed on with its reason, without a new request', () async {
      repository.onStartCall = (_) async =>
          testSession(type: CallType.voice, degraded: true, reason: 'sin cámara');
      final attempt = await useCase.execute('citizen-test', CallType.video);

      expect(attempt.outcome, CallAttemptOutcome.connected);
      expect(attempt.session?.degradedToVoice, isTrue);
      expect(attempt.session?.degradationReason, 'sin cámara');
      expect(repository.startCalls, 1);
    });

    test('unsupported wearable: no call, phones are offered', () async {
      repository.onStartCall = (type) async => testSession(type: type, status: CallStatus.unsupported);
      final attempt = await useCase.execute('citizen-test', CallType.voice);
      expect(attempt.outcome, CallAttemptOutcome.unsupported);
    });

    test('no answer within the timeout logs an unanswered call with the timeout as reason', () async {
      repository.onStartCall = neverAnswers;
      final attempt = await useCase.execute('citizen-test', CallType.video);

      expect(attempt.outcome, CallAttemptOutcome.unanswered);
      expect(repository.unansweredLogged, hasLength(1));
      expect(repository.unansweredLogged.single.$1, CallType.video);
      expect(repository.unansweredLogged.single.$2, isNotEmpty);
    });

    test('the production timeout is 30 seconds', () {
      expect(unansweredCallTimeout, const Duration(seconds: 30));
    });
  });

  group('safe zones', () {
    test('validates the draft before calling the platform', () {
      const valid = SafeZoneDraft(name: 'x', latitude: 1, longitude: 1, radiusMeters: 10);
      expect(validateSafeZoneDraft(valid), isNull);
      expect(validateSafeZoneDraft(const SafeZoneDraft(name: ' ', latitude: 1, longitude: 1, radiusMeters: 10)), isNotNull);
      expect(validateSafeZoneDraft(const SafeZoneDraft(name: 'x', latitude: 1, longitude: 1, radiusMeters: 0)), isNotNull);
      expect(validateSafeZoneDraft(const SafeZoneDraft(name: 'x', latitude: 91, longitude: 1, radiusMeters: 5)), isNotNull);
    });

    test('creates, updates, toggles and deletes through the repository', () async {
      final repository = FakeSafeZoneRepository();
      final save = SaveSafeZoneUseCase(repository: repository);
      const draft = SafeZoneDraft(name: ' Casa ', latitude: 1, longitude: 2, radiusMeters: 50);

      await save.execute('citizen-test', draft);
      final created = repository.zones.single;
      expect(created.name, 'Casa');

      await save.execute(
        'citizen-test',
        const SafeZoneDraft(name: 'Casa 2', latitude: 1, longitude: 2, radiusMeters: 80),
        existingId: created.id,
      );
      expect(repository.zones.single.radiusMeters, 80);

      await SetSafeZoneActiveUseCase(repository: repository).execute(created.id, active: false);
      expect(repository.zones.single.isActive, isFalse);

      await DeleteSafeZoneUseCase(repository: repository).execute(created.id);
      expect(repository.zones, isEmpty);
    });

    test('rejects an invalid draft without reaching the repository', () {
      final repository = FakeSafeZoneRepository();
      expect(
        () => SaveSafeZoneUseCase(repository: repository)
            .execute('c', const SafeZoneDraft(name: '', latitude: 0, longitude: 0, radiusMeters: 1)),
        throwsArgumentError,
      );
      expect(repository.zones, isEmpty);
    });
  });
}
