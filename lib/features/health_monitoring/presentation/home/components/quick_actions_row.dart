import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// "Llamar · Videollamada · Ubicación", the three shortcuts under the status card.
class QuickActionsRow extends StatelessWidget {
  final VoidCallback onCallTap;
  final VoidCallback onVideoTap;
  final VoidCallback onLocationTap;

  const new({super.key, required this.onCallTap, required this.onVideoTap, required this.onLocationTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(GuardianRadius.large);
    const divider = VerticalDivider(width: 1, indent: 12, endIndent: 12);

    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: colors.outline)),
      // Intrinsic height lets the dividers stretch to the tallest action
      child: IntrinsicHeight(
        child: Row(
          children: [
            _QuickAction(icon: Icons.phone_outlined, label: 'Llamar', onTap: onCallTap),
            divider,
            _QuickAction(icon: Icons.videocam_outlined, label: 'Videollamada', onTap: onVideoTap),
            divider,
            _QuickAction(icon: Icons.location_on_outlined, label: 'Ubicación', onTap: onLocationTap),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const new({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(GuardianRadius.medium),
                ),
                child: Icon(icon, size: 22, color: colors.primary),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: colors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
