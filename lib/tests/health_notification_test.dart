import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farahs_hub/health/health_notification_service.dart';

/// This screen provides controls for testing the health notification functionality
class HealthNotificationTestScreen extends StatelessWidget {
  const HealthNotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the health notification service
    final healthNotificationService = Get.find<HealthNotificationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Notification Test'),
        backgroundColor: Colors.pink.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildControlSection(healthNotificationService),
            const SizedBox(height: 24),
            _buildStatusSection(healthNotificationService),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Health Notification Tester',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This utility helps test the permanent health notification feature. '
              'You can enable/disable the notification and simulate different health data.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSection(HealthNotificationService service) {
    return Card(
      color: Colors.pink.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Controls',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => SwitchListTile(
                  title: const Text('Enable Health Notification'),
                  subtitle: Text(
                    service.isEnabled.value
                        ? 'Notification is active'
                        : 'Notification is disabled',
                  ),
                  value: service.isEnabled.value,
                  activeColor: Colors.pink.shade700,
                  onChanged: (value) {
                    service.toggleNotification();
                  },
                )),
            const Divider(),
            const Text(
              'Test Data',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Try to get real health data or use fallback values
                  await service.fetchHealthData();
                  
                  // If no data was found, use simulated data
                  if (service.steps.value == 0) {
                    service.steps.value = 8500;
                  }
                  
                  if (service.calories.value == 0) {
                    service.calories.value = 320.5;
                  }
                  
                  if (service.isEnabled.value) {
                    await service.updateNotificationNow();
                    Get.snackbar(
                      'Health Data Updated',
                      'Steps: ${service.steps.value}, Calories: ${service.calories.value.toStringAsFixed(1)}',
                      backgroundColor: Colors.green.withOpacity(0.7),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  } else {
                    Get.snackbar(
                      'Notification Disabled',
                      'Enable the notification first',
                      backgroundColor: Colors.orange.withOpacity(0.7),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  }
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to update health data: $e',
                    backgroundColor: Colors.red.withOpacity(0.7),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 5),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simulate Test Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(HealthNotificationService service) {
    return Obx(() => Card(
          color: Colors.green.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatusRow(
                  'Notification Status:',
                  service.isEnabled.value ? 'Enabled' : 'Disabled',
                  service.isEnabled.value ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 8),
                _buildStatusRow(
                  'Current Steps:',
                  service.steps.value.toString(),
                  Colors.blue.shade800,
                ),
                const SizedBox(height: 8),
                _buildStatusRow(
                  'Calories Burned:',
                  '${service.calories.value.toStringAsFixed(1)} kcal',
                  Colors.orange.shade800,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
