import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';

/// Figures of the last 7 days shown above the list.
class HistorySummary {
  final int totalAlerts;
  // Mean seconds from detection to acknowledgement; null when nothing was acknowledged yet
  final int? averageResponseSec;
  final int escalatedCount;

  const new({required this.totalAlerts, required this.averageResponseSec, required this.escalatedCount});
}

/// The alerts of one local day, as a section of the list.
typedef AlertDay = ({DateTime day, List<Alert> alerts});

class AlertHistoryState {
  const new({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.alerts = const [],
    this.severityFilter,
    this.page = 0,
    this.isLastPage = true,
    this.summary,
    this.careRecipientName = '',
    required this.today,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<Alert> alerts;
  // null shows every severity
  final Severity? severityFilter;
  final int page;
  final bool isLastPage;
  final HistorySummary? summary;
  final String careRecipientName;
  // Local date, so "Hoy" and "Ayer" follow the phone's day
  final DateTime today;

  String get careRecipientFirstName => careRecipientName.split(' ').first;

  /// Alerts grouped by the local day they were triggered, newest day first, as the list sections.
  List<AlertDay> get alertsByDay {
    final byDay = <DateTime, List<Alert>>{};
    for (final alert in alerts) {
      final local = alert.triggeredAt.toLocal();
      byDay.putIfAbsent(DateTime(local.year, local.month, local.day), () => []).add(alert);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    return [for (final day in days) (day: day, alerts: byDay[day]!)];
  }

  // Nullable fields take a function, so copyWith can also set them back to null
  AlertHistoryState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    ValueGetter<String?>? errorMessage,
    List<Alert>? alerts,
    ValueGetter<Severity?>? severityFilter,
    int? page,
    bool? isLastPage,
    HistorySummary? summary,
    DateTime? today,
  }) {
    return AlertHistoryState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      alerts: alerts ?? this.alerts,
      severityFilter: severityFilter != null ? severityFilter() : this.severityFilter,
      page: page ?? this.page,
      isLastPage: isLastPage ?? this.isLastPage,
      summary: summary ?? this.summary,
      careRecipientName: careRecipientName,
      today: today ?? this.today,
    );
  }
}
