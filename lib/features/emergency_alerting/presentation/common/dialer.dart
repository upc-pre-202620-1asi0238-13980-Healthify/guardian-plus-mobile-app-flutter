import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:url_launcher/url_launcher.dart';

/// Emergency services in Peru (SAMU).
const emergencyServicesNumber = '106';

/// Opens the phone dialer with the number filled in; the user presses call.
Future<void> dial(BuildContext context, String phoneNumber) async {
  final messenger = ScaffoldMessenger.of(context);
  final opened = await launchUrl(Uri(scheme: 'tel', path: phoneNumber));
  if (!opened) {
    messenger.showSnackBar(SnackBar(content: Text('No se pudo abrir el teléfono para llamar al $phoneNumber')));
  }
}

/// What every "call" button does: dials the care recipient's first emergency contact
/// ([CareContext.callNumber]). Without one, it says how to get a number to call instead of doing nothing.
Future<void> callCareRecipient(BuildContext context, CareContext careContext) async {
  final number = careContext.callNumber;
  if (number == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Agrega un contacto de emergencia para poder llamar')));
    return;
  }
  await dial(context, number);
}
