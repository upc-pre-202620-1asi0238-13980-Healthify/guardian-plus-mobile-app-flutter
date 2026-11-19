import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/profile/domain/care_recipient.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';

class CareRecipientViewModel extends ChangeNotifier {
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  final ProfileRepository repository;
  final String careRecipientProfileId;

  CareRecipientViewModel({
    required this.repository,
    required this.careRecipientProfileId,
  });

  CareRecipient? _recipient;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  CareRecipient? get recipient => _recipient;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipient = await repository.getCareRecipient(careRecipientProfileId);
    } catch (_) {
      _errorMessage =
          'No se pudo cargar la información de la persona bajo cuidado.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CareRecipient?> save({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      _errorMessage = 'Completa los nombres y apellidos.';
      _successMessage = null;
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _recipient = await repository.updateCareRecipient(
        careRecipientProfileId: careRecipientProfileId,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        birthDate: birthDate,
      );

      _successMessage = 'La información se actualizó correctamente.';

      return _recipient;
    } catch (_) {
      _errorMessage = 'No se pudieron guardar los cambios.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
