import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/device_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/link_wearable_sheet.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/link_wearable_view_model.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/wearable_details_state.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/wearable_details_view_model.dart';

/// "Pulsera": which device is linked to the care recipient, or a way to link one.
class WearableDetailsPage extends StatefulWidget {
  final WearableDetailsViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<WearableDetailsPage> createState() => _WearableDetailsPageState();
}

class _WearableDetailsPageState extends State<WearableDetailsPage> {
  late final WearableDetailsViewModel _viewModel = widget.viewModel;

  @override
  void dispose() {
    // The page owns its view model (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    final linked = await showLinkWearableSheet(
      context,
      viewModel: getIt<LinkWearableViewModel>(),
      careRecipientFirstName: _viewModel.careContext.careRecipientFirstName,
    );
    if (linked) _viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            final state = _viewModel.state;
            final wearable = state.wearable;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              children: [
                _Header(careRecipientName: state.careRecipientName),
                const SizedBox(height: 16),
                ...switch (state) {
                  WearableDetailsState(isLoading: true) => [
                    const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
                  ],
                  WearableDetailsState(errorMessage: final message?) => [
                    _ErrorCard(message: message, onRetry: _viewModel.load),
                  ],
                  _ when wearable == null => [_EmptyWearableCard(careRecipientName: state.careRecipientName, onLink: _link)],
                  _ => _linkedSections(context, wearable, state.careRecipientName),
                },
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _linkedSections(BuildContext context, WearableDevice wearable, String careRecipientName) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    const gap = SizedBox(height: 16);
    return [
      _WearableSummaryCard(wearable: wearable, careRecipientName: careRecipientName),
      gap,
      Text('INFORMACIÓN DEL DISPOSITIVO', style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
      gap,
      _WearableInformationCard(wearable: wearable),
      gap,
      _OutlinedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dispositivo vinculado', style: text.titleSmall),
            const SizedBox(height: 6),
            Text(
              'Este dispositivo está asociado al perfil de $careRecipientName.',
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
      gap,
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Guardian+ utiliza los dispositivos vinculados para identificar qué lecturas pertenecen a '
                '$careRecipientName.',
                style: text.bodySmall,
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  final String careRecipientName;

  const new({required this.careRecipientName});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox.square(
          dimension: 44,
          child: IconButton.outlined(
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Volver',
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(side: BorderSide(color: colors.outline), backgroundColor: colors.surface),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pulsera', style: text.titleLarge),
            Text(careRecipientName, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}

class _OutlinedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const new({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline),
      ),
      child: child,
    );
  }
}

class _WearableSummaryCard extends StatelessWidget {
  final WearableDevice wearable;
  final String careRecipientName;

  const new({required this.wearable, required this.careRecipientName});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return _OutlinedCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.secondaryContainer,
            child: Icon(Icons.watch_outlined, size: 24, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(wearable.deviceType.displayName, style: text.titleSmall),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Vinculada', style: text.labelSmall?.copyWith(color: colors.primary)),
                    ),
                  ],
                ),
                Text(
                  'Vinculada a $careRecipientName',
                  style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WearableInformationCard extends StatelessWidget {
  final WearableDevice wearable;

  const new({required this.wearable});

  @override
  Widget build(BuildContext context) {
    final linkedAt = wearable.linkedAt.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    final linkedAtText = '${two(linkedAt.day)}/${two(linkedAt.month)}/${linkedAt.year} ${formatClockTime(linkedAt)}';
    return _OutlinedCard(
      child: Column(
        children: [
          _InfoRow(label: 'Tipo', value: wearable.deviceType.displayName),
          const SizedBox(height: 16),
          _InfoRow(label: 'Identificador', value: wearable.serialNumber),
          const SizedBox(height: 16),
          _InfoRow(label: 'Vinculada desde', value: linkedAtText),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const new({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(label, style: text.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(width: 16),
        Expanded(child: Text(value, textAlign: TextAlign.end, style: text.bodyMedium)),
      ],
    );
  }
}

class _EmptyWearableCard extends StatelessWidget {
  final String careRecipientName;
  final VoidCallback onLink;

  const new({required this.careRecipientName, required this.onLink});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _OutlinedCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sin dispositivo vinculado', style: text.titleSmall),
          const SizedBox(height: 12),
          Text(
            '$careRecipientName todavía no tiene un dispositivo asociado.',
            style: text.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onLink, child: const Text('Vincular dispositivo')),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const new({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.errorContainer,
      borderRadius: BorderRadius.circular(GuardianRadius.medium),
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: TextStyle(color: colors.onErrorContainer)),
              Text('Toca para intentar nuevamente', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

extension on DeviceType {
  String get displayName => switch (this) {
    DeviceType.wristband => 'Guardian+ Band',
    DeviceType.smartwatch => 'Smartwatch',
    DeviceType.patch => 'Patch',
  };
}
