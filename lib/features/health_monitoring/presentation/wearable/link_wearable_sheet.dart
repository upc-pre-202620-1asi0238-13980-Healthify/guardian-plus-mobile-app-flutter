import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/device_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/link_wearable_view_model.dart';

/// Opens [LinkWearableSheet]; true once the wearable was linked, so the screen can reload its readings.
Future<bool> showLinkWearableSheet(
  BuildContext context, {
  required LinkWearableViewModel viewModel,
  required String careRecipientFirstName,
}) async {
  final linked = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => LinkWearableSheet(viewModel: viewModel, careRecipientFirstName: careRecipientFirstName),
  );
  return linked ?? false;
}

/// Bottom sheet that links the care recipient's wearable by the serial number printed on it. Opened from the
/// "Sin pulsera vinculada" chip of Home.
class LinkWearableSheet extends StatefulWidget {
  final LinkWearableViewModel viewModel;
  final String careRecipientFirstName;

  const new({super.key, required this.viewModel, required this.careRecipientFirstName});

  @override
  State<LinkWearableSheet> createState() => _LinkWearableSheetState();
}

class _LinkWearableSheetState extends State<LinkWearableSheet> {
  late final LinkWearableViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_closeWhenLinked);
  }

  @override
  void dispose() {
    // The sheet owns its view model: every opening starts with an empty form
    _viewModel.removeListener(_closeWhenLinked);
    _viewModel.dispose();
    super.dispose();
  }

  void _closeWhenLinked() {
    if (_viewModel.state.isLinked && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      // Keeps the form above the keyboard
      padding: EdgeInsets.only(left: 24, right: 24, bottom: MediaQuery.viewInsetsOf(context).bottom + 24),
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          final state = _viewModel.state;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vincular pulsera', style: text.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Ingresa el número de serie que aparece en el dispositivo de ${widget.careRecipientFirstName}.',
                style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: _viewModel.onSerialNumberChange,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Número de serie', hintText: 'GP-ESP32-S3-0001'),
              ),
              const SizedBox(height: 16),
              Text('Tipo de dispositivo', style: text.labelLarge?.copyWith(color: colors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final type in DeviceType.values)
                    FilterChip(
                      selected: state.deviceType == type,
                      onSelected: (_) => _viewModel.onDeviceTypeChange(type),
                      label: Text(type.label),
                    ),
                ],
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(state.errorMessage!, style: text.bodySmall?.copyWith(color: colors.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: state.isLoading ? null : _viewModel.link,
                child: state.isLoading
                    ? SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                      )
                    : const Text('Vincular dispositivo'),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension on DeviceType {
  String get label => switch (this) {
    DeviceType.wristband => 'Pulsera',
    DeviceType.smartwatch => 'Reloj',
    DeviceType.patch => 'Parche',
  };
}
