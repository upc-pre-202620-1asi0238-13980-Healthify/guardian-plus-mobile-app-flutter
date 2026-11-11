import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_viewmodel.dart';

class LoginPage extends StatelessWidget {
    final LoginViewmodel viewModel;
  const LoginPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: AppColors.primary,
            body: CustomScrollView(
                slivers: [
                    SliverToBoxAdapter(child: _Hero()),
                    SliverFillRemaining(
                        hasScrollBody: false,
                        child: _LoginSheet(viewModel: viewModel)
                    )
                ],
            )
        );
  }
} 

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: Colors.white, size: 40),
                SizedBox(width: 12),
                Text('Guardian+', style: TextStyle(fontSize: 22, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Cuidado\nconectado.',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'Monitoreo en tiempo real para quienes más importan.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Row(
              spacing: 32,
              children: [
                _stat('24/7', 'Monitoreo'),
                _stat('5s', 'Actualización'),
                _stat('99.8%', 'Disponibilidad'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class _LoginSheet extends StatefulWidget {
  const _LoginSheet({required this.viewModel});
  final LoginViewmodel viewModel;

  @override
  State<_LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<_LoginSheet> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final state = widget.viewModel.state;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.sheet,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const Text(
                'Iniciar sesión',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const Text(
                'Ingresa tus credenciales para continuar.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Correo electrónico', Icons.email_outlined),
              ),
              TextField(
                controller: password,
                obscureText: state.isPasswordHidden,
                decoration: _inputDecoration('Contraseña', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    onPressed: widget.viewModel.togglePasswordVisibility,
                    icon: Icon(
                      state.isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              if (state.errorMessage != null)
                Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: state.isLoading ? null : () {},
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Ingresar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }
}
