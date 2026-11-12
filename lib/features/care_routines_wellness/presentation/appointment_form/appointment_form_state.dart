import 'package:flutter/foundation.dart';

class AppointmentFormState {
  const new({this.isSaving = false, this.errorMessage, this.saved = false});

  final bool isSaving;
  final String? errorMessage;
  // Set once the platform scheduled the appointment, so the screen can go back
  final bool saved;

  AppointmentFormState copyWith({bool? isSaving, ValueGetter<String?>? errorMessage, bool? saved}) {
    return AppointmentFormState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      saved: saved ?? this.saved,
    );
  }
}
