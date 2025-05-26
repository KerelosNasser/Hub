class HealthMetric {
  final String name;
  final double value;
  final String unit;
  final DateTime timestamp;

  HealthMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
  });
}