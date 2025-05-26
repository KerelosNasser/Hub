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
    final controller = Get.find<HealthController>();

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasPermissions.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.health_and_safety,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Health Connect Integration',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'Connect with Health Connect to view your health data',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: controller.errorMessage.value.isNotEmpty
                          ? Colors.red.shade700
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.requestPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Connect Health Data'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Get.snackbar(
                        'Health Connect Info',
                        'Health Connect is Google\'s platform for health and fitness data. Install it from Google Play Store to sync your health data.',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 5),
                      );
                    },
                    child: const Text('What is Health Connect?'),
                  ),
                ],
              ),
            ),
          );
        }

        // Calculate summary metrics
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

        return RefreshIndicator(
          onRefresh: controller.fetchHealthData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Dashboard',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last 7 days summary',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 24),
                  // Summary cards
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      HealthMetricCard(
                        title: 'Steps',
                        value: totalSteps,
                        unit: 'steps',
                        icon: FontAwesomeIcons.personWalking,
                        color: Colors.blue,
                        onTap: () {},
                      ),
                      HealthMetricCard(
                        title: 'Heart Rate',
                        value: avgHeartRate,
                        unit: 'bpm',
                        icon: FontAwesomeIcons.heartPulse,
                        color: Colors.red,
                        onTap: () {},
                      ),
                      HealthMetricCard(
                        title: 'Calories',
                        value: totalCalories,
                        unit: 'kcal',
                        icon: FontAwesomeIcons.fire,
                        color: Colors.orange,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Charts
                  HealthChart(
                    data: controller.stepData,
                    title: 'Steps',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  HealthChart(
                    data: controller.heartRateData,
                    title: 'Heart Rate',
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  HealthChart(
                    data: controller.caloriesData,
                    title: 'Calories Burned',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
