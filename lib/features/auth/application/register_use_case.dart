import 'package:guardian_plus_app/features/auth/domain/auth_repository.dart';
import 'package:guardian_plus_app/features/auth/domain/registered_user_account.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase({required this.repository});

  Future<RegisteredUserAccount> execute({
    required String fullName,
    required String email,
    required String password,
  }) {
    return repository.register(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
