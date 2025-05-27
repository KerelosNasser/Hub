import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'health_controller.dart';
import 'components/health_chart.dart';
import 'components/health_metric_card.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HealthController controller = Get.find<HealthController>();
    final Color primaryTextColor = const Color(0xffedf3ff);
    final Color secondaryTextColor = primaryTextColor.withOpacity(0.7);
    final Color pageBackgroundColor = Colors.pink.shade800;
    final Color errorTextColor = Colors.yellow.shade200;
    final Color buttonTextColor = Colors.pink.shade800;
    final Color buttonBackgroundColor = const Color(0xffedf3ff);

    final screenWidth = MediaQuery.of(context).size.width;
    int gridCrossAxisCount = screenWidth < 600
        ? 2
        : (screenWidth < 900 ? 3 : 4); // Adjusted for 4 items
    double horizontalPadding = screenWidth < 600 ? 12.0 : 16.0;
    double titleFontSize = screenWidth < 600 ? 22 : 24;
    double subtitleFontSize = screenWidth < 600 ? 14 : 16;
    double connectButtonFontSize = screenWidth < 600 ? 14 : 16;

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasPermissions.value) {
          return Center(
              child: CircularProgressIndicator(color: primaryTextColor));
        }

        if (!controller.hasPermissions.value) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.health_and_safety_outlined,
                      size: screenWidth * 0.15, color: secondaryTextColor),
                  SizedBox(height: screenWidth * 0.04),
                  Text(
                    'Health Connect Integration',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: titleFontSize * 0.9,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'Connect with Health Connect to view your health data on Farah\'s Hub.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: subtitleFontSize * 0.9,
                      color: controller.errorMessage.value.isNotEmpty
                          ? errorTextColor
                          : secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.06),
                  ElevatedButton.icon(
                    icon: Icon(FontAwesomeIcons.heartPulse,
                        size: connectButtonFontSize * 1.2,
                        color: buttonTextColor),
                    label: Text('Connect Health Data',
                        style: TextStyle(
                            fontSize: connectButtonFontSize,
                            color: buttonTextColor)),
                    onPressed: controller.requestPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBackgroundColor,
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenWidth * 0.03),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  TextButton(
                    onPressed: () {
                      Get.snackbar(
                        'What is Health Connect?',
                        'Health Connect is Google\'s platform for health and fitness data. Install it from the Google Play Store to sync your health data with Farah\'s Hub.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.pink.shade900,
                        colorText: primaryTextColor,
                        duration: const Duration(seconds: 7),
                      );
                    },
                    child: Text(
                      'Learn more about Health Connect',
                      style: TextStyle(
                          color: primaryTextColor.withOpacity(0.8),
                          fontSize: subtitleFontSize * 0.85),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final totalSteps = controller.stepData.isNotEmpty
            ? controller.stepData
                .map((e) => e.value)
                .reduce((a, b) => a + b)
                .toStringAsFixed(0)
            : '0';
        final avgHeartRate = controller.heartRateData.isNotEmpty
            ? (controller.heartRateData
                        .map((e) => e.value)
                        .reduce((a, b) => a + b) /
                    controller.heartRateData.length)
                .toStringAsFixed(0)
            : '0';
        final totalCalories = controller.caloriesData.isNotEmpty
            ? controller.caloriesData
                .map((e) => e.value)
                .reduce((a, b) => a + b)
                .toStringAsFixed(0)
            : '0';

        // Calculate total sleep for the last available session or sum over a period
        // For simplicity, let's take the most recent sleep session's duration
        // Or sum all sleep sessions for the period (e.g., last night)
        double totalSleepMinutes = 0;
        if (controller.sleepData.isNotEmpty) {
          // Example: Sum of all sleep durations in the fetched period (pastWeek)
          // totalSleepMinutes = controller.sleepData.map((e) => e.value).reduce((a, b) => a + b);
          // Example: Last sleep session duration
          totalSleepMinutes = controller.sleepData.last.value;
        }
        final sleepHours = (totalSleepMinutes / 60).toStringAsFixed(1);

        return RefreshIndicator(
          onRefresh: controller.fetchHealthData,
          color: primaryTextColor,
          backgroundColor: Colors.pink.shade700,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                    child: Text(
                      'Health Dashboard',
                      style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor),
                    ),
                  ),
                  Text(
                    'Summary of the last 7 days',
                    style: TextStyle(
                        fontSize: subtitleFontSize, color: secondaryTextColor),
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  GridView.count(
                    crossAxisCount: gridCrossAxisCount, // Adjusted for 4 items
                    crossAxisSpacing: horizontalPadding / 1.5,
                    mainAxisSpacing: horizontalPadding / 1.5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      HealthMetricCard(
                        title: 'Steps',
                        value: totalSteps,
                        unit: 'steps',
                        icon: FontAwesomeIcons.personWalking,
                        iconColor: Colors.blue.shade300,
                        onTap: () {},
                      ),
                      HealthMetricCard(
                        title: 'Heart Rate',
                        value: avgHeartRate,
                        unit: 'bpm',
                        icon: FontAwesomeIcons.heartPulse,
                        iconColor: Colors.red.shade300,
                        onTap: () {},
                      ),
                      HealthMetricCard(
                        title: 'Calories',
                        value: totalCalories,
                        unit: 'kcal',
                        icon: FontAwesomeIcons.fire,
                        iconColor: Colors.orange.shade300,
                        onTap: () {},
                      ),
                      HealthMetricCard(
                        // New Sleep Card
                        title: 'Sleep',
                        value: sleepHours,
                        unit: 'hr',
                        icon: FontAwesomeIcons.solidMoon,
                        iconColor: Colors.purple.shade300,
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.06),
                  if (controller.stepData.isNotEmpty)
                    HealthChart(
                        data: controller.stepData,
                        title: 'Steps Trend',
                        chartColor: Colors.blue.shade300),
                  SizedBox(height: screenWidth * 0.04),
                  if (controller.heartRateData.isNotEmpty)
                    HealthChart(
                        data: controller.heartRateData,
                        title: 'Heart Rate Trend',
                        chartColor: Colors.red.shade300),
                  SizedBox(height: screenWidth * 0.04),
                  if (controller.caloriesData.isNotEmpty)
                    HealthChart(
                        data: controller.caloriesData,
                        title: 'Calories Burned Trend',
                        chartColor: Colors.orange.shade300),
                  SizedBox(height: screenWidth * 0.04),
                  if (controller.sleepData.isNotEmpty) // New Sleep Chart
                    HealthChart(
                        data: controller.sleepData,
                        title: 'Sleep Duration Trend',
                        chartColor: Colors.purple.shade300,
                        yAxisUnitOverride: 'min'),
                  if (controller.stepData.isEmpty &&
                      controller.heartRateData.isEmpty &&
                      controller.caloriesData.isEmpty &&
                      controller.sleepData.isEmpty &&
                      controller.hasPermissions.value)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenWidth * 0.1),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(FontAwesomeIcons.database,
                                size: screenWidth * 0.1,
                                color: secondaryTextColor),
                            SizedBox(height: screenWidth * 0.03),
                            Text(
                              'No health data found for the last 7 days.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: subtitleFontSize),
                            ),
                            SizedBox(height: screenWidth * 0.02),
                            Text(
                              'Ensure your health tracking apps (like Google Fit) are syncing with Health Connect.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: secondaryTextColor.withOpacity(0.8),
                                  fontSize: subtitleFontSize * 0.85),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
