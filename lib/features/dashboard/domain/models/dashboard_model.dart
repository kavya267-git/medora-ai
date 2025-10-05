import 'package:flutter/material.dart';

class DashboardItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const DashboardItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class HealthStat {
  final String title;
  final String value;
  final String unit;
  final Color color;
  final String trend;

  const HealthStat({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.trend,
  });
}