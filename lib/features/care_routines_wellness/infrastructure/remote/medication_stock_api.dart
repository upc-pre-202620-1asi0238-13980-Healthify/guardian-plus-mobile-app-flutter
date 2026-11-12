import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/confirm_medication_acquisition_request_dto.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/medication_stock_dto.dart';

class MedicationStockApi {
  final ApiClient client;

  const new({required this.client});

  Future<List<MedicationStockDto>> getMedicationStocks(String personUnderCareId) async {
    final List jsons = await client.get('medication-stocks/citizen/$personUnderCareId');
    return jsons.map((json) => MedicationStockDto.fromJson(json)).toList();
  }

  Future<MedicationStockDto> confirmMedicationAcquisition(
    String medicationStockId,
    ConfirmMedicationAcquisitionRequestDto request,
  ) async {
    final json = await client.put('medication-stocks/$medicationStockId/acquisition', body: request.toJson());
    return MedicationStockDto.fromJson(json);
  }
}
