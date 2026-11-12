import 'package:guardian_plus_app/features/care_routines_wellness/domain/adherence.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/adherence_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';

class GetAdherenceUseCase {
  final AdherenceRepository repository;
  
  const new({required this.repository});

  Future<Adherence> execute({
    required String personUnderCareId,
    required ReminderType type,
    required DateTime from,
    required DateTime to,
  }) {
    return repository.getAdherence(personUnderCareId: personUnderCareId, type: type, from: from, to: to);
  }
}