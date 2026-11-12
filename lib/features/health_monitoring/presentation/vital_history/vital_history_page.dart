import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/error_state.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/vital_history/components/period_average_card.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/vital_history/components/reading_item.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/vital_history/components/vital_type_filter_row.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/vital_history/vital_history_view_model.dart';

/// "Salud › Historial": the chosen period of one vital sign and the latest readings of all of them. The Health
/// page owns the view model and hands it the filter.
class VitalHistoryPage extends StatelessWidget {
  final VitalHistoryViewModel viewModel;

  const new({super.key, required this.viewModel});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Próximamente')));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final state = viewModel.state;
        if (state.isLoading && state.readings.isEmpty) return const Center(child: CircularProgressIndicator());
        if (state.errorMessage != null && state.readings.isEmpty) {
          return ErrorState(message: state.errorMessage!, onRetry: viewModel.load);
        }

        // An empty period still shows the chips and the card with "Sin lecturas esta semana"
        final type = state.chartType;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            VitalTypeFilterRow(types: state.filter.types, selected: type, onSelect: viewModel.selectType),
            const SizedBox(height: 12),
            PeriodAverageCard(
              type: type,
              period: state.period,
              average: state.average(type),
              min: state.min(type),
              max: state.max(type),
              values: state.chartValues(type),
              days: state.days,
            ),
            for (final reading in state.recentReadings) ...[
              const SizedBox(height: 12),
              ReadingItem(
                reading: reading,
                diastolic: state.diastolicFor(reading),
                withinRange: state.isWithinRange(reading),
                today: state.today,
              ),
            ],
            const SizedBox(height: 16),
            // The PDF record and the weekly report are not built in this app yet
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showComingSoon(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Exportar PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(onPressed: () => _showComingSoon(context), child: const Text('Reporte semanal')),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
