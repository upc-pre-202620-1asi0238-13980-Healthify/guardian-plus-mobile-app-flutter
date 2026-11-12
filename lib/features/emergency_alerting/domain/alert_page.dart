import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';

/// One page of the alert history, most recent first.
class AlertPage {
  final List<Alert> alerts;
  final int page;
  final int totalPages;
  final int totalElements;

  const new({required this.alerts, required this.page, required this.totalPages, required this.totalElements});

  bool get isLast => page >= totalPages - 1;
}
