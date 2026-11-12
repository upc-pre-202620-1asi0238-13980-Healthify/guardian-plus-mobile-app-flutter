import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/alert_history_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/components/day_header.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/components/history_alert_item.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/components/history_summary_card.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/components/severity_filter_row.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';

/// "Historial" tab of the Alerts screen. The screen around it owns the view model.
class AlertHistoryView extends StatefulWidget {
  final AlertHistoryViewModel viewModel;
  final ValueChanged<String> onAlertTap;

  const new({super.key, required this.viewModel, required this.onAlertTap});

  @override
  State<AlertHistoryView> createState() => _AlertHistoryViewState();
}

class _AlertHistoryViewState extends State<AlertHistoryView> {
  // How close to the end of the list, in pixels, the next page starts loading
  static const _loadMoreThreshold = 400.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreNearEnd);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreNearEnd() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) widget.viewModel.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final state = viewModel.state;
        final scheme = Theme.of(context).colorScheme;
        // A first page that does not fill the screen cannot be scrolled, so the next one is asked for here too
        if (!state.isLastPage) WidgetsBinding.instance.addPostFrameCallback((_) => _loadMoreNearEnd());
        final text = Theme.of(context).textTheme;

        final List<Widget> body;
        if (state.isLoading) {
          body = [const Padding(padding: EdgeInsets.all(32), child: LoadingView())];
        } else if (state.errorMessage != null && state.alerts.isEmpty) {
          body = [ErrorRetryView(message: state.errorMessage!, onRetry: viewModel.loadHistory)];
        } else if (state.alerts.isEmpty) {
          final filter = state.severityFilter;
          body = [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
              child: Column(
                children: [
                  if (filter == null) Text('Sin alertas en el historial', style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    filter == null
                        ? 'Cuando ocurra una alerta, quedará registrada aquí con todo su seguimiento.'
                        : 'No hay alertas de severidad ${filter.label.toLowerCase()}.',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ];
        } else {
          body = [
            for (final (:day, :alerts) in state.alertsByDay) ...[
              DayHeader(key: ValueKey(day), day: day, today: state.today),
              for (final alert in alerts) ...[
                const SizedBox(height: 12),
                HistoryAlertItem(
                  key: ValueKey(alert.id),
                  alert: alert,
                  careRecipientFirstName: state.careRecipientFirstName,
                  onTap: () => widget.onAlertTap(alert.id),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ];
        }

        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: ListView(
            controller: _scrollController,
            // Pull to refresh also works when the list is short
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              SeverityFilterRow(selected: state.severityFilter, onSelected: viewModel.selectSeverity),
              if (state.summary case final summary?) ...[
                const SizedBox(height: 12),
                HistorySummaryCard(summary: summary),
              ],
              const SizedBox(height: 12),
              ...body,
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
