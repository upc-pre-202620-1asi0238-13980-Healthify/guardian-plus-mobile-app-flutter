import 'package:flutter/widgets.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

String localizeAuthMessage(BuildContext context, String message) {
  switch (message.trim()) {
    case 'Completa todos los campos para continuar':
    case 'Completa todos los campos para continuar.':
      return context.l10n.authCompleteFields;

    case 'Te enviamos un nuevo código.':
      return context.l10n.otpNewCodeSent;

    default:
      return message;
  }
}
