import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_signs.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_repository.dart';

class GetLiveVitalSignsUseCase {
  final VitalSignRepository repository;

  const new({required this.repository});

  Future<LiveVitalSigns> execute(String careRecipientProfileId) {
    return repository.getLiveVitalSigns(careRecipientProfileId);
  }
}
