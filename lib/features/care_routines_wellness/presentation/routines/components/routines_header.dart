import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// Top bar of the Routines section: avatar of the signed-in member and whose wellbeing is followed.
class RoutinesHeader extends StatelessWidget {
  final String userInitials;
  final String careRecipientName;

  const new({super.key, required this.userInitials, required this.careRecipientName});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: colors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(GuardianRadius.medium),
                    ),
                    child: Text(userInitials, style: text.titleMedium?.copyWith(color: colors.primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienestar de $careRecipientName',
                          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        Text('Rutinas', style: text.titleLarge?.copyWith(color: colors.onSurface)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
