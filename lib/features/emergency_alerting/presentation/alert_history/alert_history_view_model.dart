import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/core/time/server_clock.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_history_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/alert_history_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';

/// Every past alert of the person under care, by day, with how each one ended (US13).
class AlertHistoryViewModel extends ChangeNotifier {
  final GetAlertHistoryUseCase getAlertHistory;
  final ServerClock serverClock;
  final CareContextStore careContextStore;

  new({required this.getAlertHistory, required this.serverClock, required this.careContextStore}) {
    loadHistory();
  }

  static const summaryDays = 7;

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  late AlertHistoryState _state = AlertHistoryState(careRecipientName: _careContext.careRecipientName, today: _today());
  AlertHistoryState get state => _state;

  bool _disposed = false;

  Future<void> loadHistory() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    await Future.wait([_loadFirstPage(), _loadSummary()]);
  }

  /// Pull to refresh: keeps the current list on screen while the new one loads.
  Future<void> refresh() => Future.wait([_loadFirstPage(), _loadSummary()]);

  Future<void> selectSeverity(Severity? severity) async {
    if (severity == _state.severityFilter) return;
    _emit(
      _state.copyWith(
        severityFilter: () => severity,
        alerts: const [],
        isLoading: true,
        isLoadingMore: false,
        errorMessage: () => null,
      ),
    );
    await _loadFirstPage();
  }

  /// Called when the list reaches its end; asks for the next page unless it was the last one.
  Future<void> loadMore() async {
    final state = _state;
    if (state.isLastPage || state.isLoadingMore || state.isLoading) return;
    _emit(_state.copyWith(isLoadingMore: true));
    try {
      final page = await getAlertHistory.execute(
        careRecipientProfileId: _careContext.careRecipientProfileId,
        severity: state.severityFilter,
        page: state.page + 1,
      );
      // A filter chosen meanwhile replaced the list; this page belongs to the old one
      if (_state.severityFilter != state.severityFilter) {
        _emit(_state.copyWith(isLoadingMore: false));
        return;
      }
      final known = _state.alerts.map((alert) => alert.id).toSet();
      _emit(
        _state.copyWith(
          isLoadingMore: false,
          alerts: [..._state.alerts, ...page.alerts.where((alert) => !known.contains(alert.id))],
          page: page.page,
          isLastPage: page.isLast,
        ),
      );
    } catch (_) {
      // The list already on screen stays usable; scrolling again retries
      _emit(_state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _loadFirstPage() async {
    final severity = _state.severityFilter;
    try {
      final page = await getAlertHistory.execute(
        careRecipientProfileId: _careContext.careRecipientProfileId,
        severity: severity,
      );
      // Only the answer for the filter still selected counts
      if (_state.severityFilter != severity) return;
      _emit(
        _state.copyWith(
          isLoading: false,
          errorMessage: () => null,
          alerts: page.alerts,
          page: page.page,
          isLastPage: page.isLast,
          today: _today(),
        ),
      );
    } catch (e) {
      if (_state.severityFilter != severity) return;
      _emit(_state.copyWith(isLoading: false, errorMessage: () => errorMessageOf(e, 'No se pudo cargar el historial')));
    }
  }

  // Always over every severity: the summary describes the week, not the current filter
  Future<void> _loadSummary() async {
    try {
      final page = await getAlertHistory.execute(
        careRecipientProfileId: _careContext.careRecipientProfileId,
        from: serverClock.now().subtract(const Duration(days: summaryDays)),
        size: GetAlertHistoryUseCase.maxPageSize,
      );
      _emit(_state.copyWith(summary: summarize(page.alerts, page.totalElements)));
    } catch (_) {
      // The list works without the summary
    }
  }

  @visibleForTesting
  static HistorySummary summarize(List<Alert> alerts, int total) {
    final responseTimes = [
      for (final alert in alerts)
        if (alert.acknowledgedAt != null) alert.acknowledgedAt!.difference(alert.triggeredAt).inSeconds,
    ];
    return HistorySummary(
      totalAlerts: total,
      averageResponseSec: responseTimes.isEmpty
          ? null
          : (responseTimes.reduce((a, b) => a + b) / responseTimes.length).round(),
      // An alert that reached secondary contacts or everyone was escalated at least once
      escalatedCount: alerts
          .where(
            (alert) =>
                alert.currentRecipientLevel == RecipientLevel.secondary ||
                alert.currentRecipientLevel == RecipientLevel.broadcast,
          )
          .length,
    );
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void _emit(AlertHistoryState state) {
    // A request can finish after the user has left the screen
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
