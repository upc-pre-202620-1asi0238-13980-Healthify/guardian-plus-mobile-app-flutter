import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// "Cerrar sesión": asks before signing out; true once confirmed.
Future<bool> showLogoutDialog(BuildContext context, {required String careRecipientFirstName}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const CircleAvatar(
        radius: 24,
        backgroundColor: GuardianColors.destructivePastel,
        child: Icon(Icons.logout, color: GuardianColors.destructive),
      ),
      title: const Text('Cerrar sesión'),
      content: Text(
        '¿Deseas cerrar tu sesión en Guardian+? Dejarás de ver la información de $careRecipientFirstName hasta que '
        'vuelvas a iniciar sesión.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Cerrar sesión', style: TextStyle(color: GuardianColors.destructive)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
