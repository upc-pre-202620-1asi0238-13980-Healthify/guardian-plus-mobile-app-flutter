import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock.dart';

class StockState {
  const new({
    this.isLoading = false,
    this.isLoaded = false,
    this.errorMessage,
    this.stocks = const [],
    this.restockingId,
    this.message,
  });

  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;
  final List<MedicationStock> stocks;
  // Stock receiving a new package, so only its button shows progress
  final String? restockingId;
  final String? message;

  /// Medications that run out within the restock threshold, the first one leading the warning.
  List<MedicationStock> get lowStocks {
    return stocks.where((stock) => stock.restockRecommended).toList()
      ..sort((a, b) => a.remainingDaysOfSupply.compareTo(b.remainingDaysOfSupply));
  }

  // Nullable fields take a function, so copyWith can also set them back to null
  StockState copyWith({
    bool? isLoading,
    bool? isLoaded,
    ValueGetter<String?>? errorMessage,
    List<MedicationStock>? stocks,
    ValueGetter<String?>? restockingId,
    ValueGetter<String?>? message,
  }) {
    return StockState(
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      stocks: stocks ?? this.stocks,
      restockingId: restockingId != null ? restockingId() : this.restockingId,
      message: message != null ? message() : this.message,
    );
  }
}
