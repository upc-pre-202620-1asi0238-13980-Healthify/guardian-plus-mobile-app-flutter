import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';

class MedicationFormState {
  const new({this.isSaving = false, this.errorMessage, this.savedTime});

  final bool isSaving;
  final String? errorMessage;
  // Set once the platform scheduled the dose, so the screen can go back
  final LocalTime? savedTime;

  MedicationFormState copyWith({
    bool? isSaving,
    ValueGetter<String?>? errorMessage,
    ValueGetter<LocalTime?>? savedTime,
  }) {
    return MedicationFormState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      savedTime: savedTime != null ? savedTime() : this.savedTime,
    );
  }
}
