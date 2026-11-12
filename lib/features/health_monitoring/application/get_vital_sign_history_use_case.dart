import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_reading.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_repository.dart';

/// Past readings in general, not the live ones.
class GetVitalSignHistoryUseCase {
  final VitalSignRepository repository;

  const new({required this.repository});

  Future<List<VitalSignReading>> execute(
    String careRecipientProfileId, {
    required DateTime from,
    required DateTime to,
  }) {
    return repository.getVitalSignHistory(careRecipientProfileId, from: from, to: to);
  }
}
