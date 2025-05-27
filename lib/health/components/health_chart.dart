import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../health_model.dart';
import 'package:intl/intl.dart';

class HealthChart extends StatelessWidget {
  final List<HealthMetric> data;
  final String title;
  final Color chartColor;
  final String?
      yAxisUnitOverride; // Optional: 'hr' or 'min' to adjust formatting

  const HealthChart({
    super.key,
    required this.data,
    required this.title,
    required this.chartColor,
    this.yAxisUnitOverride,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBackgroundColor = Colors.pink.shade900;
    final Color primaryTextColor = const Color(0xffedf3ff);
    final Color secondaryTextColor = primaryTextColor.withOpacity(0.7);
    final screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = screenWidth < 600 ? 16 : 18;
    final double latestValueFontSize = screenWidth < 600 ? 14 : 16;
    final double chartHeight = screenWidth < 600 ? 180 : 200;

    if (data.isEmpty) {
      return Card(
        elevation: 4,
        color: cardBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Center(
            child: Text(
              'No $title data available for the past 7 days.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: secondaryTextColor, fontSize: latestValueFontSize),
            ),
          ),
        ),
      );
    }

    final sortedData = List<HealthMetric>.from(data)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    String displayUnit = yAxisUnitOverride ?? sortedData.first.unit;
    double lastValue = sortedData.last.value;
    int fractionDigits = (displayUnit == "steps" ||
            displayUnit == "kcal" ||
            displayUnit == "min")
        ? 0
        : 1;
    if (displayUnit == "hr" && yAxisUnitOverride == "hr") {
      // If displaying sleep in hours
      lastValue = lastValue / 60; // Convert minutes to hours for display
      fractionDigits = 1;
    }

    return Card(
      elevation: 4,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor),
            ),
            SizedBox(height: screenWidth * 0.015),
            Text(
              // For sleep, if original data is in minutes, convert to hours for "Latest" display if needed
              'Latest: ${lastValue.toStringAsFixed(fractionDigits)} ${yAxisUnitOverride ?? sortedData.last.unit}',
              style:
                  TextStyle(fontSize: latestValueFontSize, color: chartColor),
            ),
            SizedBox(height: screenWidth * 0.04),
            SizedBox(
              height: chartHeight,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    verticalInterval:
                        _calculateInterval(sortedData, true, yAxisUnitOverride),
                    horizontalInterval: _calculateInterval(
                        sortedData, false, yAxisUnitOverride),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                          color: secondaryTextColor.withOpacity(0.2),
                          strokeWidth: 0.5);
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                          color: secondaryTextColor.withOpacity(0.2),
                          strokeWidth: 0.5);
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: screenWidth *
                            0.12, // Increased for potentially larger numbers
                        getTitlesWidget: (value, meta) {
                          if (meta.max % 5 != 0 &&
                              value % (meta.appliedInterval / 2) != 0 &&
                              screenWidth < 600) {
                            if (value == meta.min || value == meta.max) {
                              // always show min/max
                            } else {
                              return Container();
                            }
                          }
                          String label = value.toInt().toString();
                          if (yAxisUnitOverride == 'hr' &&
                              title.toLowerCase().contains('sleep')) {
                            // If chart itself is meant to show hours, but data is in minutes
                            // label = (value / 60).toStringAsFixed(1); // This assumes Y-axis values are already scaled to hours
                          }

                          return Text(
                            label,
                            style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: screenWidth * 0.025),
                            textAlign: TextAlign.left,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: screenWidth * 0.08,
                        getTitlesWidget: (value, meta) {
                          if (sortedData.isEmpty) return Container();
                          int index = value.toInt();
                          if (index >= 0 && index < sortedData.length) {
                            if (index == 0 ||
                                index == sortedData.length - 1 ||
                                index == (sortedData.length / 2).floor()) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  DateFormat('d MMM')
                                      .format(sortedData[index].timestamp),
                                  style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: screenWidth * 0.025),
                                ),
                              );
                            }
                          }
                          return Container();
                        },
                        interval: (sortedData.length > 1)
                            ? (sortedData.length / 3)
                                .floorToDouble()
                                .toDouble()
                                .clamp(1, _calculateDateInterval(sortedData))
                            : 1,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                          color: secondaryTextColor.withOpacity(0.3),
                          width: 0.5)),
                  minX: 0,
                  maxX: (sortedData.length - 1).toDouble(),
                  minY: _calculateMinY(sortedData, yAxisUnitOverride),
                  maxY: _calculateMaxY(sortedData, yAxisUnitOverride),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _createSpots(sortedData, yAxisUnitOverride),
                      isCurved: true,
                      color: chartColor,
                      barWidth: screenWidth < 600 ? 2.5 : 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: screenWidth >= 600),
                      belowBarData: BarAreaData(
                        show: true,
                        color: chartColor.withOpacity(0.2),
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

  List<FlSpot> _createSpots(
      List<HealthMetric> sortedData, String? yAxisUnitOverride) {
    return sortedData.asMap().entries.map((entry) {
      double value = entry.value.value;
      // if(yAxisUnitOverride == 'hr' && entry.value.unit == 'min' && title.toLowerCase().contains('sleep')){
      //    value = value / 60; // Convert to hours for plotting if chart Y-axis is hours
      // }
      return FlSpot(entry.key.toDouble(), value);
    }).toList();
  }

  double _calculateMinY(List<HealthMetric> data, String? yAxisUnitOverride) {
    if (data.isEmpty) return 0;
    double minVal = data.map((e) {
      // double val = e.value;
      // if(yAxisUnitOverride == 'hr' && e.unit == 'min' && title.toLowerCase().contains('sleep')){
      //    val = val / 60;
      // }
      // return val;
      return e.value;
    }).reduce((a, b) => a < b ? a : b);
    return (minVal * 0.85).floorToDouble();
  }

  double _calculateMaxY(List<HealthMetric> data, String? yAxisUnitOverride) {
    if (data.isEmpty) return 100;
    double maxVal = data.map((e) {
      // double val = e.value;
      // if(yAxisUnitOverride == 'hr' && e.unit == 'min' && title.toLowerCase().contains('sleep')){
      //    val = val / 60;
      // }
      // return val;
      return e.value;
    }).reduce((a, b) => a > b ? a : b);
    return (maxVal * 1.15).ceilToDouble();
  }

  double _calculateInterval(
      List<HealthMetric> data, bool isVertical, String? yAxisUnitOverride) {
    if (data.isEmpty) return 10;
    if (isVertical) {
      double minVal =
          _calculateMinY(data, yAxisUnitOverride); // Use calculated min Y
      double maxVal =
          _calculateMaxY(data, yAxisUnitOverride); // Use calculated max Y
      double range = maxVal - minVal;
      if (range == 0) {
        return (maxVal > 0 ? maxVal / 5 : 10).clamp(1, 1000).toDouble();
      }
      double interval = (range / 4).ceilToDouble();
      return interval > 0 ? interval : 10;
    } else {
      return (data.length / 4).ceilToDouble().clamp(1, data.length.toDouble());
    }
  }

  double _calculateDateInterval(List<HealthMetric> data) {
    if (data.length <= 1) return 1;
    return (data.length / 3).floorToDouble().clamp(1.0, data.length.toDouble());
  }
}
