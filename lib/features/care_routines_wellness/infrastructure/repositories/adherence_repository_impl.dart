import 'package:guardian_plus_app/features/care_routines_wellness/domain/adherence.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/adherence_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/adherence_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/reminder_enums_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/adherence_api.dart';

class AdherenceRepositoryImpl implements AdherenceRepository {
  final AdherenceApi api;

  const new({required this.api});

  @override
  Future<Adherence> getAdherence({
    required String personUnderCareId,
    required ReminderType type,
    required DateTime from,
    required DateTime to,
  }) async {
    final dto = await api.getAdherence(
      personUnderCareId,
      type: type.toApi(),
      from: _isoDate(from),
      to: _isoDate(to),
    );
    return dto.toDomain();
  }

  // The platform takes plain dates (LocalDate), e.g. 2026-11-11
  String _isoDate(DateTime date) => date.toIso8601String().substring(0, 10);
}
