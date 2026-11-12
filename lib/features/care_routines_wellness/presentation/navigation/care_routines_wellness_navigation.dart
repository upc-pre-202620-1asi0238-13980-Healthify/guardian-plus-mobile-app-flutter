import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/activity/activity_page.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/activity/activity_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/appointment_form/appointment_form_page.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/appointment_form/appointment_form_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/appointments/appointments_page.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/appointments/appointments_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/hydration/hydration_page.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/hydration/hydration_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/inactivity/inactivity_page.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/inactivity/inactivity_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/medication/medication_page.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/medication/medication_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/medication_form/medication_form_page.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/medication_form/medication_form_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routine_category.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/sleep/sleep_page.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/sleep/sleep_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/stock/stock_page.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/stock/stock_view_model.dart';

// Screens of Care Routines & Wellness. Each one gets a fresh view model (registerFactory) and disposes it.

/// Opens the screen of one routine from the routines tab; completes when the user comes back.
Future<void> openRoutineCategory(BuildContext context, RoutineCategory category) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) => switch (category) {
        RoutineCategory.medication => MedicationPage(viewModel: getIt<MedicationViewModel>()),
        RoutineCategory.appointments => AppointmentsPage(viewModel: getIt<AppointmentsViewModel>()),
        RoutineCategory.activity => ActivityPage(viewModel: getIt<ActivityViewModel>()),
        RoutineCategory.hydration => HydrationPage(viewModel: getIt<HydrationViewModel>()),
        RoutineCategory.sleep => SleepPage(viewModel: getIt<SleepViewModel>()),
        RoutineCategory.inactivity => InactivityPage(viewModel: getIt<InactivityViewModel>()),
        RoutineCategory.stock => StockPage(viewModel: getIt<StockViewModel>()),
      },
    ),
  );
}

/// "Nueva toma". A form goes back to the list below it with the confirmation to show, or null if cancelled.
Future<String?> openMedicationForm(BuildContext context) {
  return Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (context) => MedicationFormPage(viewModel: getIt<MedicationFormViewModel>())),
  );
}

/// "Nueva cita", with the confirmation to show, or null if cancelled.
Future<String?> openAppointmentForm(BuildContext context) {
  return Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (context) => AppointmentFormPage(viewModel: getIt<AppointmentFormViewModel>())),
  );
}
