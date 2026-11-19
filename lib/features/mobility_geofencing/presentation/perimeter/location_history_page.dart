import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/application/location_use_cases.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/location_reading.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/common/mobility_widgets.dart';

/// "Bitácora de movimientos": the location history of the care recipient, newest first.
class LocationHistoryPage extends StatefulWidget {
  final GetLocationHistoryUseCase getLocationHistory;
  final String fragileCitizenId;
  final String careRecipientFirstName;

  const LocationHistoryPage({
    super.key,
    required this.getLocationHistory,
    required this.fragileCitizenId,
    required this.careRecipientFirstName,
  });

  @override
  State<LocationHistoryPage> createState() => _LocationHistoryPageState();
}

class _LocationHistoryPageState extends State<LocationHistoryPage> {
  late Future<List<LocationReading>> _future = widget.getLocationHistory.execute(widget.fragileCitizenId);

  void _retry() => setState(() => _future = widget.getLocationHistory.execute(widget.fragileCitizenId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movimientos de ${widget.careRecipientFirstName}')),
      body: FutureBuilder<List<LocationReading>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return MobilityErrorState(message: 'No se pudo cargar la bitácora de movimientos', onRetry: _retry);
          }
          final readings = snapshot.data!;
          if (readings.isEmpty) return const Center(child: Text('Aún no hay movimientos registrados'));
          return ListView.separated(
            itemCount: readings.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final reading = readings[index];
              final where = reading.insideSafeZone
                  ? 'Dentro de ${reading.activeSafeZoneName ?? 'una zona segura'}'
                  : 'Fuera de las zonas seguras';
              return ListTile(
                leading: Icon(
                  reading.insideSafeZone ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                  color: reading.insideSafeZone ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                ),
                title: Text(where),
                subtitle: Text('${reading.latitude.toStringAsFixed(5)}, ${reading.longitude.toStringAsFixed(5)}'),
                trailing: Text(formatDateTime(reading.timestamp)),
              );
            },
          );
        },
      ),
    );
  }
}
