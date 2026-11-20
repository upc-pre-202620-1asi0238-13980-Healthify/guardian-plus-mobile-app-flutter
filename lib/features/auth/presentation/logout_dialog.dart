import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

Future<bool> showLogoutDialog(
  BuildContext context, {
  required String careRecipientFirstName,
}) async {
  final l10n = context.l10n;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const CircleAvatar(
        radius: 24,
        backgroundColor: GuardianColors.destructivePastel,
        child: Icon(Icons.logout, color: GuardianColors.destructive),
      ),
      title: Text(l10n.authLogoutTitle),
      content: Text(
        ' '
        ' '
        '',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(
            l10n.authLogoutConfirm,
            style: const TextStyle(color: GuardianColors.destructive),
          ),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
