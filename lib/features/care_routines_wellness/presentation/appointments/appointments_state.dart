import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';

class AppointmentsState {
  const new({
    this.isLoading = false,
    this.isLoaded = false,
    this.errorMessage,
    this.appointments = const [],
    required this.now,
    this.cancellingId,
    this.message,
  });

  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;
  // Appointments still ahead (scheduled or already notified), soonest first
  final List<Reminder> appointments;
  final DateTime now;
  final String? cancellingId;
  final String? message;

  Reminder? get nextAppointment => appointments.firstOrNull;

  List<Reminder> get laterAppointments => appointments.skip(1).toList();

  // Nullable fields take a function, so copyWith can also set them back to null
  AppointmentsState copyWith({
    bool? isLoading,
    bool? isLoaded,
    ValueGetter<String?>? errorMessage,
    List<Reminder>? appointments,
    DateTime? now,
    ValueGetter<String?>? cancellingId,
    ValueGetter<String?>? message,
  }) {
    return AppointmentsState(
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      appointments: appointments ?? this.appointments,
      now: now ?? this.now,
      cancellingId: cancellingId != null ? cancellingId() : this.cancellingId,
      message: message != null ? message() : this.message,
    );
  }
}
