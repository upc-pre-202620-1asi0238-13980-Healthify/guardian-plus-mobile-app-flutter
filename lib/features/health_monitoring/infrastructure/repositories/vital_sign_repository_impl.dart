import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_signs.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_reading.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_repository.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/mappers/vital_sign_mapper.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/vital_sign_api.dart';

class VitalSignRepositoryImpl implements VitalSignRepository {
  final VitalSignApi api;

  const new({required this.api});

  @override
  Future<LiveVitalSigns> getLiveVitalSigns(String careRecipientProfileId) async {
    final dto = await api.getLiveVitalSigns(careRecipientProfileId);
    return dto.toDomain();
  }

  @override
  Future<List<VitalSignReading>> getVitalSignHistory(
    String careRecipientProfileId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final dtos = await api.getVitalSignHistory(careRecipientProfileId, from: _isoDate(from), to: _isoDate(to));
    return dtos.map((dto) => dto.toDomainOrNull()).nonNulls.toList();
  }

  // The platform reads plain dates (ISO, yyyy-MM-dd)
  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
