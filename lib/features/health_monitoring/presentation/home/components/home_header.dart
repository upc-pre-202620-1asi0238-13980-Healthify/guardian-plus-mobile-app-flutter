import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// "Buenos días, María · Todo bajo control": greeting of the signed-in member and the bell to the alerts.
class HomeHeader extends StatelessWidget {
  final String userInitials;
  final String userFirstName;
  final String careRecipientFirstName;
  final bool allWithinRange;
  final int hour;
  final VoidCallback onBellTap;
  final VoidCallback onAvatarTap;

  const new({
    super.key,
    required this.userInitials,
    required this.userFirstName,
    required this.careRecipientFirstName,
    required this.allWithinRange,
    required this.hour,
    required this.onBellTap,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final greeting = switch (hour) {
      < 12 => 'Buenos días, $userFirstName',
      < 19 => 'Buenas tardes, $userFirstName',
      _ => 'Buenas noches, $userFirstName',
    };

    return Row(
      children: [
        // The member's initials open the account options, such as signing out
        Tooltip(
          message: 'Cuenta',
          child: Material(
            color: colors.primary,
            borderRadius: BorderRadius.circular(GuardianRadius.medium),
            child: InkWell(
              onTap: onAvatarTap,
              borderRadius: BorderRadius.circular(GuardianRadius.medium),
              child: SizedBox.square(
                dimension: 48,
                child: Center(child: Text(userInitials, style: text.titleMedium?.copyWith(color: colors.onPrimary))),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              Text(
                allWithinRange ? 'Todo bajo control' : 'Revisa a $careRecipientFirstName',
                style: text.titleLarge?.copyWith(color: colors.onSurface),
              ),
            ],
          ),
        ),
        // The unread count of the prototype lives in Emergency & Alerting, so the bell only opens that tab
        SizedBox(
          width: 44,
          height: 44,
          child: IconButton.outlined(
            onPressed: onBellTap,
            tooltip: 'Abrir alertas',
            icon: const Icon(Icons.notifications_outlined, size: 20),
            style: IconButton.styleFrom(
              side: BorderSide(color: colors.outline),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GuardianRadius.medium)),
            ),
          ),
        ),
      ],
    );
  }
}
