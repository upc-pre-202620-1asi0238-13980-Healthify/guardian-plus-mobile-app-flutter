import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_banner.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_form_layout.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_progress_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_top_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/stock/stock_state.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/stock/stock_view_model.dart';

class StockPage extends StatefulWidget {
  final StockViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  late final StockViewModel _viewModel = widget.viewModel;

  @override
  void dispose() {
    // The page owns its view model: every visit starts with a fresh one (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoutineTopBar(
        title: 'Stock de medicinas',
        subtitle: 'Inventario del tratamiento',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: RoutineMessageEffect(
        source: _viewModel,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            final state = _viewModel.state;
            return switch (state) {
              StockState(isLoaded: false, errorMessage: null) => const RoutineLoadingState(),
              StockState(isLoaded: false) => RoutineErrorState(
                message: state.errorMessage ?? '',
                onRetry: _viewModel.load,
              ),
              StockState(stocks: []) => const RoutineEmptyState(
                icon: Icons.layers_outlined,
                title: 'Sin medicamentos registrados',
                message: 'Los medicamentos aparecerán aquí cuando se registre su stock.',
              ),
              _ => _StockList(state: state, onAddPackage: _viewModel.addPackage),
            };
          },
        ),
      ),
    );
  }
}

class _StockList extends StatelessWidget {
  final StockState state;
  final ValueChanged<MedicationStock> onAddPackage;

  const new({required this.state, required this.onAddPackage});

  @override
  Widget build(BuildContext context) {
    final lowest = state.lowStocks.firstOrNull;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        if (lowest != null) ...[
          RoutineBanner(
            icon: Icons.layers_outlined,
            title: 'Reposición recomendada',
            message: plural(
              _wholeDaysOfSupply(lowest),
              '${lowest.medicationName} tiene disponibilidad para ${_wholeDaysOfSupply(lowest)} día o menos.',
              '${lowest.medicationName} tiene disponibilidad para ${_wholeDaysOfSupply(lowest)} días o menos.',
            ),
            tone: RoutineTone.orange,
          ),
          const SizedBox(height: 10),
        ],
        const RoutineSectionTitle(text: 'Medicamentos'),
        for (final stock in state.stocks) ...[
          const SizedBox(height: 10),
          _StockCard(
            key: ValueKey(stock.id),
            stock: stock,
            isRestocking: state.restockingId == stock.id,
            onAddPackage: () => onAddPackage(stock),
          ),
        ],
        const SizedBox(height: 10),
        const RoutineSectionTitle(text: 'Cómo se calcula'),
        const SizedBox(height: 10),
        const RoutineInfoLine(
          icon: Icons.assignment_turned_in_outlined,
          text: 'El balance se actualiza con cada dosis confirmada y cada nueva adquisición.',
        ),
      ],
    );
  }
}

/// One medication: name, balance, a bar against a full package and when it runs out.
class _StockCard extends StatelessWidget {
  final MedicationStock stock;
  final bool isRestocking;
  final VoidCallback onAddPackage;

  const new({super.key, required this.stock, required this.isRestocking, required this.onAddPackage});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final low = stock.restockRecommended;
    final (visualContainer, visualContent) = (low ? RoutineTone.yellow : RoutineTone.mint).colorsIn(colors);
    final days = _wholeDaysOfSupply(stock);
    final depletion = stock.estimatedDepletionDate;
    final title = [stock.medicationName, ?stock.dosage].join(' ');
    final consumption = stock.dailyConsumption;
    final dailyDoses = consumption % 1 == 0 ? consumption.toInt().toString() : consumption.toString();
    final remaining = stock.remainingDoses;
    final runsOut = plural(
      days,
      'Se agotará aproximadamente en $days día',
      'Se agotará aproximadamente en $days días',
    );

    return RoutineCard(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: visualContainer,
                borderRadius: BorderRadius.circular(GuardianRadius.medium),
              ),
              child: Icon(Icons.medication_outlined, size: 26, color: visualContent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: text.titleSmall?.copyWith(color: colors.onSurface))),
                      low
                          ? const RoutineBadge(text: 'Stock bajo', tone: RoutineTone.orange)
                          : const RoutineBadge(text: 'Disponible'),
                    ],
                  ),
                  Text(
                    plural(
                      remaining,
                      '$dailyDoses dosis al día · $remaining unidad restante',
                      '$dailyDoses dosis al día · $remaining unidades restantes',
                    ),
                    style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: RoutineProgressBar(
                      percentage: stock.packagePercentage,
                      progress: low ? colors.tertiary : colors.secondary,
                    ),
                  ),
                  Text(
                    !low && depletion != null ? 'Próxima compra estimada: ${formatDayOfMonth(depletion)}' : runsOut,
                    style: text.labelMedium?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (low) ...[
          const SizedBox(height: 12),
          RoutinePrimaryButton(text: 'Añadir envase', isLoading: isRestocking, onPressed: onAddPackage),
        ],
      ],
    );
  }
}

// "para 3 días": a partial day still counts as a day of medication at hand
int _wholeDaysOfSupply(MedicationStock stock) => stock.remainingDaysOfSupply.ceil();
