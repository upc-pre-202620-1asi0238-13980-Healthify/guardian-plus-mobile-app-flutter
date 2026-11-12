import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';

class GetAlertHistoryUseCase {
  final AlertRepository repository;

  const new({required this.repository});

  static const defaultPageSize = 20;
  // Largest page the platform accepts (AlertsController.MAX_PAGE_SIZE)
  static const maxPageSize = 100;

  Future<AlertPage> execute({
    required String careRecipientProfileId,
    Severity? severity,
    DateTime? from,
    DateTime? to,
    int page = 0,
    int size = defaultPageSize,
  }) {
    return repository.getAlertHistory(
      careRecipientProfileId: careRecipientProfileId,
      severity: severity,
      from: from,
      to: to,
      page: page,
      size: size,
    );
  }
}
