import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';
import 'package:guardian_plus_app/features/profile/domain/user_profile.dart';

class PersonalDataViewModel extends ChangeNotifier {
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
  final String userId;

  PersonalDataViewModel({required this.repository, required this.userId});

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await repository.findUserProfile(userId);
    } catch (_) {
      _errorMessage = 'No se pudo cargar tu información personal.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserProfile?> save({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    final trimmedFirstName = firstName.trim();
    final trimmedLastName = lastName.trim();
    final trimmedPhoneNumber = phoneNumber.trim();

    if (trimmedFirstName.isEmpty ||
        trimmedLastName.isEmpty ||
        trimmedPhoneNumber.isEmpty) {
      _errorMessage = 'Completa todos los campos antes de guardar.';
      _successMessage = null;
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_profile == null) {
        _profile = await repository.createUserProfile(
          userId: userId,
          firstName: trimmedFirstName,
          lastName: trimmedLastName,
          phoneNumber: trimmedPhoneNumber,
        );
      } else {
        final updatedProfile = await repository.updateUserProfile(
          userProfileId: _profile!.id,
          firstName: trimmedFirstName,
          lastName: trimmedLastName,
        );

        _profile = await repository.updateContactInformation(
          userProfileId: updatedProfile.id,
          phoneNumber: trimmedPhoneNumber,
        );
      }

      _successMessage = 'Tus datos se actualizaron correctamente.';

      return _profile;
    } catch (_) {
      _errorMessage = 'No se pudieron guardar los cambios.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
