import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// Message and "Reintentar" shown when a health screen has nothing to show yet.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const new({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(GuardianRadius.medium),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
}
