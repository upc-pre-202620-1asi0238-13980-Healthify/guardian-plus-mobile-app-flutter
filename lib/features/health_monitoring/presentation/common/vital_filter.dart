import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';

// Blood pressure is one tile, one chip and one chart for both halves, so bpDia is never listed on its own
const displayedVitalTypes = [
  VitalSignType.hr,
  VitalSignType.bpSys,
  VitalSignType.spo2,
  VitalSignType.temp,
  VitalSignType.respRate,
];

/// How far back "Historial" looks.
enum HistoryPeriod {
  day(1),
  week(7),
  month(30);

  final int dayCount;

  const HistoryPeriod(this.dayCount);
}

/// One row of "Buscar y filtrar", in the order of the prototype.
enum VitalFilterOption {
  heartRate('Ritmo cardíaco', type: VitalSignType.hr),
  bloodPressure('Presión arterial', type: VitalSignType.bpSys),
  oxygenSaturation('Saturación de oxígeno', type: VitalSignType.spo2),
  temperature('Temperatura', type: VitalSignType.temp),
  respiration('Respiración', type: VitalSignType.respRate),
  day('Día', period: HistoryPeriod.day),
  week('Semana', period: HistoryPeriod.week),
  month('Mes', period: HistoryPeriod.month),
  normal('Normal'),
  observation('En observación');

  final String label;
  final VitalSignType? type;
  final HistoryPeriod? period;

  const VitalFilterOption(this.label, {this.type, this.period});
}

/// What "Buscar y filtrar" has selected. Within a group nothing selected means no restriction, so the empty
/// filter shows every vital sign of the last week, whatever its state.
class VitalFilter {
  final Set<VitalFilterOption> options;

  const new({this.options = const {}});

  List<VitalSignType> get types {
    final selected = options.map((option) => option.type).nonNulls.toList();
    final types = selected.isEmpty ? [...displayedVitalTypes] : selected;
    return types..sort((a, b) => displayedVitalTypes.indexOf(a).compareTo(displayedVitalTypes.indexOf(b)));
  }

  // The periods exclude each other, see toggle
  HistoryPeriod get period => options.map((option) => option.period).nonNulls.firstOrNull ?? HistoryPeriod.week;

  bool get isEmpty => options.isEmpty;

  bool includes(VitalSignType type) => types.contains(type == VitalSignType.bpDia ? VitalSignType.bpSys : type);

  bool includesState(bool withinRange) {
    final normal = options.contains(VitalFilterOption.normal);
    final observation = options.contains(VitalFilterOption.observation);
    return (!normal && !observation) || (withinRange && normal) || (!withinRange && observation);
  }

  // A history has one period, so picking one replaces the other two
  VitalFilter toggle(VitalFilterOption option) {
    if (options.contains(option)) return VitalFilter(options: {...options}..remove(option));
    if (option.period != null) {
      return VitalFilter(options: {...options.where((other) => other.period == null), option});
    }
    return VitalFilter(options: {...options, option});
  }

  @override
  bool operator ==(Object other) =>
      other is VitalFilter && other.options.length == options.length && other.options.containsAll(options);

  @override
  int get hashCode => Object.hashAllUnordered(options);
}
