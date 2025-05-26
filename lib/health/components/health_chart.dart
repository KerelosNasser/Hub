import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../health_model.dart';

class HealthChart extends StatelessWidget {
  final List<HealthMetric> data;
  final String title;
  final Color color;

  const HealthChart({
    super.key,
    required this.data,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text('No $title data available'),
          ),
        ),
      );
    }

    // Sort data by timestamp
    final sortedData = List<HealthMetric>.from(data)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Latest: ${sortedData.last.value.toStringAsFixed(1)} ${sortedData.last.unit}',
              style: TextStyle(fontSize: 16, color: color),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _createSpots(sortedData),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _createSpots(List<HealthMetric> sortedData) {
    if (sortedData.isEmpty) return [];

    final spots = <FlSpot>[];
    final firstDate = sortedData.first.timestamp;

    for (var i = 0; i < sortedData.length; i++) {
      final metric = sortedData[i];
      final days = metric.timestamp.difference(firstDate).inHours / 24;
      spots.add(FlSpot(days, metric.value));
    }

    return spots;
  }
}
