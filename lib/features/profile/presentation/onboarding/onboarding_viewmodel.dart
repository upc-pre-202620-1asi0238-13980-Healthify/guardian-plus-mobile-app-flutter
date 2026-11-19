import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/application/care_context_load.dart';
import 'package:guardian_plus_app/features/profile/application/complete_onboarding_use_case.dart';
import 'package:guardian_plus_app/features/profile/domain/care_relationship.dart';
import 'package:guardian_plus_app/features/profile/presentation/onboarding/onboarding_state.dart';

class OnboardingViewModel extends ChangeNotifier {
  final CompleteOnboardingUseCase completeOnboarding;

  OnboardingViewModel({required this.completeOnboarding});

  OnboardingState _state = const OnboardingState();

  OnboardingState get state => _state;

  bool _started = false;

  void start({
    required bool needsUserProfile,
    required bool needsCareRecipient,
    String? suggestedFullName,
  }) {
    if (_started) {
      return;
    }

    _started = true;

    final words =
        suggestedFullName
            ?.trim()
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .toList() ??
        <String>[];

    var firstName = '';
    var lastName = '';

    if (words.isNotEmpty) {
      if (words.length == 1) {
        firstName = words.first;
      } else {
        final lastNameWordCount = min(2, words.length - 1);

        firstName = words.take(words.length - lastNameWordCount).join(' ');

        lastName = words.skip(words.length - lastNameWordCount).join(' ');
      }
    }

    _state = _state.copyWith(
      showUserProfile: needsUserProfile,
      showCareRecipient: needsCareRecipient,
      firstName: firstName,
      lastName: lastName,
    );

    notifyListeners();
  }

  void onFirstNameChanged(String value) {
    _state = _state.copyWith(firstName: value, errorMessage: null);

    notifyListeners();
  }

  void onLastNameChanged(String value) {
    _state = _state.copyWith(lastName: value, errorMessage: null);

    notifyListeners();
  }

  void onPhoneNumberChanged(String value) {
    _state = _state.copyWith(phoneNumber: value, errorMessage: null);

    notifyListeners();
  }

  void onCareRecipientFirstNameChanged(String value) {
    _state = _state.copyWith(careRecipientFirstName: value, errorMessage: null);

    notifyListeners();
  }

  void onCareRecipientLastNameChanged(String value) {
    _state = _state.copyWith(careRecipientLastName: value, errorMessage: null);

    notifyListeners();
  }

  void onCareRecipientBirthDateChanged(DateTime value) {
    _state = _state.copyWith(careRecipientBirthDate: value, errorMessage: null);

    notifyListeners();
  }

  void onRelationshipTypeChanged(RelationshipType value) {
    _state = _state.copyWith(relationshipType: value, errorMessage: null);

    notifyListeners();
  }

  Future<bool> submit({required String userAccountId}) async {
    if (_state.isLoading) {
      return false;
    }

    final validationError = _validate();

    if (validationError != null) {
      _state = _state.copyWith(errorMessage: validationError);

      notifyListeners();

      return false;
    }

    final normalizedPhone = _state.phoneNumber.replaceAll(RegExp(r'\s+'), '');

    final data = OnboardingData(
      userProfile: _state.showUserProfile
          ? UserProfileData(
              firstName: _state.firstName.trim(),
              lastName: _state.lastName.trim(),
              phoneNumber: normalizedPhone,
            )
          : null,
      careRecipient: _state.showCareRecipient
          ? CareRecipientData(
              firstName: _state.careRecipientFirstName.trim(),
              lastName: _state.careRecipientLastName.trim(),
              birthDate: _state.careRecipientBirthDate!,
              relationshipType: _state.relationshipType,
            )
          : null,
    );

    _state = _state.copyWith(isLoading: true, errorMessage: null);

    notifyListeners();

    try {
      final result = await completeOnboarding.execute(
        userAccountId: userAccountId,
        data: data,
      );

      if (result is! CareContextReady) {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: 'No se pudo completar tu perfil',
        );

        notifyListeners();

        return false;
      }

      _state = _state.copyWith(isLoading: false, errorMessage: null);

      notifyListeners();

      return true;
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );

      notifyListeners();

      return false;
    }
  }

  String? _validate() {
    if (_state.showUserProfile) {
      if (_state.firstName.trim().isEmpty ||
          _state.lastName.trim().isEmpty ||
          _state.phoneNumber.trim().isEmpty) {
        return 'Completa tus datos para continuar';
      }

      final phoneNumber = _state.phoneNumber.replaceAll(RegExp(r'\s+'), '');

      if (!RegExp(r'^\+?\d{9,15}$').hasMatch(phoneNumber)) {
        return 'Ingresa un celular válido, por ejemplo +51987654321';
      }
    }

    if (_state.showCareRecipient) {
      if (_state.careRecipientFirstName.trim().isEmpty ||
          _state.careRecipientLastName.trim().isEmpty) {
        return 'Ingresa el nombre de la persona que cuidas';
      }

      final birthDate = _state.careRecipientBirthDate;

      if (birthDate == null) {
        return 'Selecciona su fecha de nacimiento';
      }

      final today = DateTime.now();

      final todayOnly = DateTime(today.year, today.month, today.day);

      final birthDateOnly = DateTime(
        birthDate.year,
        birthDate.month,
        birthDate.day,
      );

      if (birthDateOnly.isAfter(todayOnly)) {
        return 'La fecha de nacimiento no puede estar en el futuro';
      }
    }

    return null;
  }
}
