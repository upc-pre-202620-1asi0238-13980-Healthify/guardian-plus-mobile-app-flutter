import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/call/call_view_model.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/common/mobility_widgets.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/perimeter/perimeter_monitoring_view_model.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/perimeter/perimeter_monitoring_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Direct communication screen (US-23). One page, four faces: video, voice (degraded or requested),
/// telemetry-only status check and unanswered call.
class CallPage extends StatefulWidget {
  final CallViewModel viewModel;

  const CallPage({super.key, required this.viewModel});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late final CallViewModel _viewModel = widget.viewModel;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _dial(String phone) async {
    final opened = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!opened) _toast('No se pudo abrir el marcador');
  }

  Future<void> _hangUp() async {
    await _viewModel.end();
    if (mounted && _viewModel.state.phase == CallPhase.ended) Navigator.pop(context);
  }

  Future<void> _buzz() async {
    _toast(await _viewModel.buzzWearable('Llamada no atendida: el cuidador solicita tu atención'));
  }

  void _lastLocation() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PerimeterMonitoringPage(viewModel: getIt<PerimeterMonitoringViewModel>()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final careContext = _viewModel.careContext;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;
        final title = switch (state.phase) {
          CallPhase.telemetryOnly => 'Verificación de estado',
          CallPhase.unanswered => 'Intento de llamada',
          _ => careContext.careRecipientName,
        };

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  switch (state.phase) {
                    CallPhase.videoActive => 'En videollamada',
                    CallPhase.voiceActive => 'Llamada de voz en curso',
                    CallPhase.telemetryOnly => 'Canal de contacto',
                    CallPhase.unanswered => careContext.careRecipientName,
                    _ => 'Llamada',
                  },
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          body: switch (state.phase) {
            CallPhase.connecting => const Center(child: CircularProgressIndicator()),
            CallPhase.failed => MobilityErrorState(
              message: state.errorMessage ?? 'No se pudo establecer la llamada',
              onRetry: _viewModel.start,
            ),
            CallPhase.ended => Center(
              child: Text(
                state.session?.durationSeconds == null
                    ? 'Llamada finalizada'
                    : 'Llamada finalizada · ${formatDuration(state.session!.durationSeconds!)}',
              ),
            ),
            CallPhase.videoActive || CallPhase.voiceActive => _ActiveCall(
              state: state,
              firstName: careContext.careRecipientFirstName,
              careRecipientName: careContext.careRecipientName,
              onHangUp: _hangUp,
            ),
            CallPhase.telemetryOnly => _TelemetryOnly(
              state: state,
              firstName: careContext.careRecipientFirstName,
              onDial: _dial,
            ),
            CallPhase.unanswered => _Unanswered(
              state: state,
              firstName: careContext.careRecipientFirstName,
              onBuzz: _buzz,
              onRetry: _viewModel.start,
              onLastLocation: _lastLocation,
            ),
          },
        );
      },
    );
  }
}

class _ActiveCall extends StatelessWidget {
  final CallState state;
  final String firstName;
  final String careRecipientName;
  final VoidCallback onHangUp;

  const _ActiveCall({
    required this.state,
    required this.firstName,
    required this.careRecipientName,
    required this.onHangUp,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final video = state.phase == CallPhase.videoActive;
    final capabilities = state.capabilities;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (state.notice != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: colors.tertiaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_outlined),
                const SizedBox(width: 12),
                Expanded(child: Text('Modelo sin cámara detectado. ${state.notice}')),
              ],
            ),
          ),
        if (capabilities?.wristbandModel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${capabilities!.wristbandModel}${video ? '' : ' · Sin cámara'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        Container(
          height: 280,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: video ? colors.onSurface : colors.secondaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 44,
                child: Text(
                  _initials(careRecipientName),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                careRecipientName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: video ? colors.surface : null),
              ),
              const SizedBox(height: 4),
              _Elapsed(key: ValueKey(state.session?.callId), color: video ? colors.surface : null),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ToggleButton(icon: Icons.mic_none, activeIcon: Icons.mic_off),
            if (video) _ToggleButton(icon: Icons.videocam_outlined, activeIcon: Icons.videocam_off_outlined),
            _ToggleButton(icon: Icons.volume_up_outlined, activeIcon: Icons.volume_off_outlined),
            const SizedBox(width: 12),
            IconButton.filled(
              tooltip: 'Finalizar llamada',
              style: IconButton.styleFrom(backgroundColor: colors.error, foregroundColor: colors.onError),
              onPressed: state.isBusy ? null : onHangUp,
              icon: const Icon(Icons.call_end),
            ),
          ],
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}

class _ToggleButton extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;

  const _ToggleButton({required this.icon, required this.activeIcon});

  @override
  State<_ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<_ToggleButton> {
  bool _off = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => setState(() => _off = !_off),
      icon: Icon(_off ? widget.activeIcon : widget.icon),
    );
  }
}

/// Connected time, counted from the moment the session shows up.
class _Elapsed extends StatefulWidget {
  final Color? color;

  const _Elapsed({super.key, this.color});

  @override
  State<_Elapsed> createState() => _ElapsedState();
}

class _ElapsedState extends State<_Elapsed> {
  final _stopwatch = Stopwatch()..start();
  late final Timer _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));

  @override
  void initState() {
    super.initState();
    _timer;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Conectado · ${formatDuration(_stopwatch.elapsed.inSeconds)}',
      style: TextStyle(color: widget.color),
    );
  }
}

class _TelemetryOnly extends StatelessWidget {
  final CallState state;
  final String firstName;
  final Future<void> Function(String phone) onDial;

  const _TelemetryOnly({required this.state, required this.firstName, required this.onDial});

  @override
  Widget build(BuildContext context) {
    final capabilities = state.capabilities;
    final citizenPhone = capabilities?.citizenPhone ?? state.session?.citizenPhone;
    final caregiverPhone = capabilities?.caregiverPhone ?? state.session?.caregiverPhone;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capabilities?.wristbandModel ?? 'Pulsera vinculada',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Este modelo no admite llamadas: no dispone de altavoz ni micrófono. '
                  'Puedes contactar por teléfono.',
                ),
                const SizedBox(height: 12),
                if (capabilities != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Capability('Telemetría', capabilities.supportsTelemetry),
                      _Capability('Alertas hápticas', capabilities.supportsHapticAlerts),
                      _Capability('Altavoz', capabilities.hasSpeaker),
                      _Capability('Micrófono', capabilities.hasMicrophone),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Opciones de contacto telefónico', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (citizenPhone == null && caregiverPhone == null)
          const Text('No hay números de contacto registrados.'),
        if (citizenPhone != null) ...[
          Text('Llamar al móvil de $firstName'),
          Text(citizenPhone, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => onDial(citizenPhone),
            icon: const Icon(Icons.phone),
            label: const Text('Llamar a línea celular'),
          ),
          const SizedBox(height: 16),
        ],
        if (caregiverPhone != null) ...[
          const Text('Llamar a acompañante / cuidador'),
          Text(caregiverPhone, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => onDial(caregiverPhone),
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Llamar a cuidador'),
          ),
        ],
      ],
    );
  }
}

class _Capability extends StatelessWidget {
  final String label;
  final bool available;

  const _Capability(this.label, this.available);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(available ? Icons.check : Icons.close, size: 16, color: available ? colors.primary : colors.error),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _Unanswered extends StatelessWidget {
  final CallState state;
  final String firstName;
  final Future<void> Function() onBuzz;
  final VoidCallback onRetry;
  final VoidCallback onLastLocation;

  const _Unanswered({
    required this.state,
    required this.firstName,
    required this.onBuzz,
    required this.onRetry,
    required this.onLastLocation,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hapticSupported = state.capabilities?.supportsHapticAlerts ?? true;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: colors.errorContainer, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Llamada no atendida', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'No hubo respuesta en la pulsera de $firstName'
                '${state.unansweredAt == null ? '' : ' a las ${formatTime(state.unansweredAt)}'}. '
                'Se guardó el registro en la bitácora.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('¿Qué deseas hacer ahora?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: hapticSupported && !state.isBusy ? onBuzz : null,
          icon: const Icon(Icons.vibration),
          label: const Text('Enviar alerta vibratoria (Zumbido)'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.phone_forwarded_outlined), label: const Text('Reintentar llamada')),
        Center(child: TextButton.icon(onPressed: onLastLocation, icon: const Icon(Icons.location_on_outlined), label: const Text('Ver última ubicación GPS reportada'))),
        const SizedBox(height: 16),
        Text('Registro de historial', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (state.logs.isEmpty) const Text('Aún no hay llamadas registradas.'),
        for (final entry in state.logs) _LogTile(entry: entry),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  final CallLogEntry entry;

  const _LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final kind = entry.callType == CallType.video ? 'Videollamada' : 'Llamada de voz';
    final result = switch (entry.status) {
      CallStatus.unanswered => ('$kind perdida', 'Sin respuesta', Icons.phone_missed_outlined),
      CallStatus.ended => (
        kind,
        entry.durationSeconds == null ? 'Finalizada' : formatDuration(entry.durationSeconds!),
        Icons.call_made,
      ),
      CallStatus.active => (kind, 'Iniciada', Icons.call_made),
      CallStatus.unsupported => ('$kind no disponible', 'No admitida', Icons.phone_disabled_outlined),
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(result.$3),
      title: Text(result.$1),
      subtitle: Text(entry.notes ?? formatDateTime(entry.timestamp)),
      trailing: Text(result.$2),
    );
  }
}
