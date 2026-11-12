import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_filter.dart';

/// Opens "Buscar y filtrar"; the filter picked on "Aplicar", or null if the sheet was closed.
Future<VitalFilter?> showVitalFilterSheet(BuildContext context, {required VitalFilter applied}) {
  return showModalBottomSheet<VitalFilter>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    builder: (context) => VitalFilterSheet(applied: applied),
  );
}

/// "Buscar y filtrar": picks the criteria in a draft that only reaches the screen on "Aplicar".
class VitalFilterSheet extends StatefulWidget {
  final VitalFilter applied;

  const new({super.key, required this.applied});

  @override
  State<VitalFilterSheet> createState() => _VitalFilterSheetState();
}

class _VitalFilterSheetState extends State<VitalFilterSheet> {
  // Draft and query are purely visual until "Aplicar", so they live here and not in a view model
  late VitalFilter _draft = widget.applied;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final visibleOptions = VitalFilterOption.values.where((option) => _matches(option.label, _query)).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Buscar y filtrar', style: text.titleLarge?.copyWith(color: colors.onSurface)),
                      Text(
                        'Selecciona uno o más criterios',
                        style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Cerrar',
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: GuardianColors.neutralMuted,
                    minimumSize: const Size.square(48),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Buscar entre las opciones',
                prefixIcon: Icon(Icons.search, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            // Only the list scrolls, so "Limpiar · Aplicar" stay in reach
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final option in visibleOptions) ...[
                      _FilterOptionRow(
                        label: option.label,
                        selected: _draft.options.contains(option),
                        onTap: () => setState(() => _draft = _draft.toggle(option)),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (visibleOptions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Ninguna opción coincide con la búsqueda',
                          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _draft = const VitalFilter()),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: BorderSide(color: colors.primary),
                    ),
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _draft),
                    child: Text('Aplicar · ${_draft.options.length}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const new({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(GuardianRadius.medium);
    return Material(
      color: selected ? colors.primaryContainer : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: selected ? colors.primary : colors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurface)),
              ),
              if (selected) Icon(Icons.check, size: 18, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// "oxigeno" finds "Saturación de oxígeno": accents and case do not count
bool _matches(String label, String query) => query.trim().isEmpty || _normalized(label).contains(_normalized(query.trim()));

const _accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n'};

String _normalized(String text) =>
    text.toLowerCase().split('').map((character) => _accents[character] ?? character).join();
