import 'package:flutter/material.dart';

/// The five destinations of the bottom navigation bar, in the order of the team prototype.
enum TopLevelDestination {
  home(Icons.home_outlined, 'Inicio'),
  health(Icons.show_chart, 'Salud'),
  alerts(Icons.notifications_none, 'Alertas'),
  routines(Icons.assignment_turned_in_outlined, 'Rutinas'),
  location(Icons.location_on_outlined, 'Ubicación');

  final IconData icon;
  final String label;

  const TopLevelDestination(this.icon, this.label);
}
