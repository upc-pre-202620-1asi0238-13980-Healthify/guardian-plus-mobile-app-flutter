import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings.dart';

// A few sensible values inside the 15–300 s the platform accepts
const _timeoutOptions = [30, 60, 90, 120, 180, 300];

/// How long the primary contact has to acknowledge before the alert escalates (US11).
class AckTimeoutSelector extends StatelessWidget {
  final int selectedSeconds;
  final bool enabled;
  final ValueChanged<int> onSelected;

  const new({super.key, required this.selectedSeconds, required this.enabled, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // A value set elsewhere (e.g. 45 s through the API) still shows as selected
    final options = {..._timeoutOptions, selectedSeconds}
        .where((seconds) => seconds >= AckTimeoutLimits.minSeconds && seconds <= AckTimeoutLimits.maxSeconds)
        .toList()
      ..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiempo de espera antes de escalar',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: enabled ? colors.onSurface : colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final seconds in options)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$seconds s', style: dataLabelStyle),
                      selected: seconds == selectedSeconds,
                      onSelected: enabled ? (_) => onSelected(seconds) : null,
                      showCheckmark: false,
                      shape: const StadiumBorder(),
                      selectedColor: colors.primary,
                      labelStyle: TextStyle(
                        color: seconds == selectedSeconds ? colors.onPrimary : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
