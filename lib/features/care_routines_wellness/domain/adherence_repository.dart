import 'package:guardian_plus_app/features/care_routines_wellness/domain/adherence.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';

abstract class AdherenceRepository {
  Future<Adherence> getAdherence({
    required String personUnderCareId,
    required ReminderType type,
    required DateTime from,
    required DateTime to,
  });
}