import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/live_vitals_state.dart';

// The backend sends English names; the app speaks Spanish
extension VitalSignTypeLabels on VitalSignType {
  String get label => switch (this) {
    VitalSignType.hr => 'Ritmo cardíaco',
    VitalSignType.bpSys || VitalSignType.bpDia => 'Presión arterial',
    VitalSignType.spo2 => 'Saturación',
    VitalSignType.temp => 'Temperatura',
    VitalSignType.respRate => 'Respiración',
  };

  // Card titles of "Ahora", shown in capitals
  String get title => switch (this) {
    VitalSignType.hr => 'Frecuencia cardíaca',
    VitalSignType.bpSys || VitalSignType.bpDia => 'Presión arterial',
    VitalSignType.spo2 => 'Saturación O₂',
    VitalSignType.temp => 'Temperatura',
    VitalSignType.respRate => 'Respiración',
  };

  String get displayUnit => switch (this) {
    VitalSignType.hr => 'lpm',
    VitalSignType.bpSys || VitalSignType.bpDia => 'mmHg',
    VitalSignType.spo2 => '%',
    VitalSignType.temp => '°C',
    VitalSignType.respRate => 'rpm',
  };

  // Chip text of the "Historial" filter row
  String get shortLabel => switch (this) {
    VitalSignType.hr => 'Ritmo',
    VitalSignType.bpSys || VitalSignType.bpDia => 'Presión',
    VitalSignType.spo2 => 'SpO₂',
    VitalSignType.temp => 'Temp',
    VitalSignType.respRate => 'Respir',
  };

  IconData get icon => switch (this) {
    VitalSignType.hr => Icons.favorite_border,
    VitalSignType.bpSys || VitalSignType.bpDia => Icons.bar_chart,
    VitalSignType.spo2 => Icons.monitor_heart_outlined,
    VitalSignType.temp => Icons.thermostat,
    VitalSignType.respRate => Icons.air,
  };

  // Temperature is the only one read with a decimal (36.6 °C); the rest are whole numbers
  String format(double value) => switch (this) {
    VitalSignType.temp => value.toStringAsFixed(1),
    _ => value.round().toString(),
  };
}

extension VitalTrendLabels on VitalTrend {
  String get label => switch (this) {
    VitalTrend.stable => 'Estable',
    VitalTrend.rising => 'En aumento',
    VitalTrend.falling => 'En descenso',
  };
}

// "Hace 3 min" reads "hace 3 min" in the middle of a sentence
String lowercaseFirst(String text) => text.isEmpty ? text : text[0].toLowerCase() + text.substring(1);
