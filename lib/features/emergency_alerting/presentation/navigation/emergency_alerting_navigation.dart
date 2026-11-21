import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_view_model.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/perimeter/perimeter_monitoring_page.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/perimeter/perimeter_monitoring_view_model.dart';

// Screens of Emergency & Alerting. Each one gets a fresh view model (registerFactory) and disposes it;
// every function completes when the user comes back.

Future<void> openAlertDetail(BuildContext context, String alertId) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) => AlertDetailPage(
        viewModel: getIt<AlertDetailViewModel>(param1: alertId),
        onViewMap: () => _openLocation(context),
      ),
    ),
  );
}

// "Ver en mapa": Mobility & Geofencing's live position and safe zones of the person under care
Future<void> _openLocation(BuildContext context) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute(builder: (context) => PerimeterMonitoringPage(viewModel: getIt<PerimeterMonitoringViewModel>())),
  );
}

Future<void> openAlertSettings(BuildContext context) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute(builder: (context) => AlertSettingsPage(viewModel: getIt<AlertSettingsViewModel>())),
  );
}

Future<void> openEmergencyContacts(BuildContext context) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute(builder: (context) => EmergencyContactsPage(viewModel: getIt<EmergencyContactsViewModel>())),
  );
}
