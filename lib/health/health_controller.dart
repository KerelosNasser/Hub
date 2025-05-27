import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'health_model.dart';
import 'dart:io';
import 'package:external_app_launcher/external_app_launcher.dart';

class HealthController extends GetxController {
  final Health health = Health();

  final RxBool isLoading = true.obs;
  final RxBool hasPermissions = false.obs;
  final RxList<HealthMetric> stepData = <HealthMetric>[].obs;
  final RxList<HealthMetric> heartRateData = <HealthMetric>[].obs;
  final RxList<HealthMetric> caloriesData = <HealthMetric>[].obs;
  final RxList<HealthMetric> sleepData =
      <HealthMetric>[].obs; // New list for sleep
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeHealthService();
  }

  Future<void> _initializeHealthService() async {
    isLoading.value = true;
    try {
      if (Platform.isAndroid) {
        final isAvailable = await health.isHealthConnectAvailable();
        if (!isAvailable) {
          errorMessage.value =
              'Health Connect is not available on this device.';
          isLoading.value = false;
          Get.snackbar(
            'Health Connect Required',
            'Please install Health Connect from the Google Play Store to use this feature.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 7),
            mainButton: TextButton(
              onPressed: () async {
                try {
                  await health.installHealthConnect();
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Could not open Play Store. Please install Health Connect manually.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Install Health Connect',
                  style: TextStyle(color: Colors.white)),
            ),
          );
          return;
        }
      }
      await requestPermissions();
    } catch (e) {
      errorMessage.value =
          'Failed to initialize health service: ${e.toString()}';
      isLoading.value = false;
    }
  }

  Future<void> requestPermissions() async {
    isLoading.value = true;
    try {
      if (Platform.isAndroid) {
        var activityStatus = await Permission.activityRecognition.status;
        if (activityStatus.isDenied) {
          activityStatus = await Permission.activityRecognition.request();
        }
        if (activityStatus.isPermanentlyDenied ||
            activityStatus.isRestricted ||
            activityStatus.isDenied) {
          errorMessage.value =
              'Activity recognition permission is required for step counting. Please enable it in app settings.';
          isLoading.value = false;
          return;
        }
      }

      final types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.WORKOUT,
        HealthDataType.SLEEP_SESSION, // Add sleep session
      ];

      final permissions = types.map((type) => HealthDataAccess.READ).toList();

      bool? authResult = await health.requestAuthorization(
        types,
        permissions: permissions,
      );

      hasPermissions.value = authResult ?? false;

      if (hasPermissions.value) {
        errorMessage.value = '';
        await fetchHealthData();
      } else {
        isLoading.value = false;
        errorMessage.value =
            'Health permissions are required. Please grant permissions in the Health Connect app.';
        Get.snackbar(
          'Health Connect Permissions',
          'Open Health Connect app and grant permissions to Farah\'s Hub to view your health data.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 7),
          mainButton: TextButton(
            onPressed: _openHealthConnect,
            child: const Text('Open Health Connect',
                style: TextStyle(color: Colors.white)),
          ),
        );
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value =
          'Failed to request health permissions: ${e.toString()}';
      Get.snackbar(
        'Permission Error',
        'Error requesting health permissions. Ensure Health Connect is installed, updated, and permissions are granted within it.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 7),
      );
    }
  }

  Future<void> _openHealthConnect() async {
    try {
      const String healthConnectPackageName =
          "com.google.android.apps.healthdata";
      bool isInstalled = await LaunchApp.isAppInstalled(
        androidPackageName: healthConnectPackageName,
        iosUrlScheme: '',
      );

      if (isInstalled) {
        await LaunchApp.openApp(androidPackageName: healthConnectPackageName);
      } else {
        Get.snackbar(
          'Health Connect Not Installed',
          'Please install Health Connect from the Google Play Store.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 7),
          mainButton: TextButton(
            onPressed: () async {
              try {
                await health.installHealthConnect();
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Could not open Play Store. Please install Health Connect manually.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Install Health Connect',
                style: TextStyle(color: Colors.white)),
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Open Health Connect Manually',
        'Could not open Health Connect automatically. Please open it from your app drawer to manage permissions.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 7),
      );
    }
  }

  Future<void> fetchHealthData() async {
    if (!hasPermissions.value) {
      errorMessage.value = "Permissions not granted to fetch health data.";
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final now = DateTime.now();
      final pastWeek = now.subtract(const Duration(days: 7));

      stepData.clear();
      heartRateData.clear();
      caloriesData.clear();
      sleepData.clear(); // Clear sleep data

      await Future.wait([
        _fetchStepsDataInternal(pastWeek, now),
        _fetchHeartRateDataInternal(pastWeek, now),
        _fetchCaloriesDataInternal(pastWeek, now),
        _fetchSleepDataInternal(pastWeek, now), // Fetch sleep data
      ]);

      if (stepData.isEmpty &&
          heartRateData.isEmpty &&
          caloriesData.isEmpty &&
          sleepData.isEmpty) {
        errorMessage.value =
            'No health data found for the past 7 days in Health Connect.';
      } else {
        Get.snackbar(
          'Success',
          'Health data updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch health data: ${e.toString()}';
      Get.snackbar(
        'Data Fetch Error',
        'Could not retrieve health data. Please check permissions in Health Connect.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchStepsDataInternal(
      DateTime startDate, DateTime endDate) async {
    try {
      final steps = await health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.STEPS],
      );
      stepData.assignAll(steps
          .map((step) => HealthMetric(
                name: 'Steps',
                value: double.tryParse(step.value.toString()) ?? 0.0,
                unit: 'steps',
                timestamp: step.dateFrom,
              ))
          .toList());
    } catch (e) {
      // Non-blocking
    }
  }

  Future<void> _fetchHeartRateDataInternal(
      DateTime startDate, DateTime endDate) async {
    try {
      final heartRates = await health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.HEART_RATE],
      );
      heartRateData.assignAll(heartRates
          .map((hr) => HealthMetric(
                name: 'Heart Rate',
                value: double.tryParse(hr.value.toString()) ?? 0.0,
                unit: 'bpm',
                timestamp: hr.dateFrom,
              ))
          .toList());
    } catch (e) {
      // Non-blocking
    }
  }

  Future<void> _fetchCaloriesDataInternal(
      DateTime startDate, DateTime endDate) async {
    try {
      final calories = await health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      caloriesData.assignAll(calories
          .map((cal) => HealthMetric(
                name: 'Calories',
                value: double.tryParse(cal.value.toString()) ?? 0.0,
                unit: 'kcal',
                timestamp: cal.dateFrom,
              ))
          .toList());
    } catch (e) {
      // Non-blocking
    }
  }

  Future<void> _fetchSleepDataInternal(
      DateTime startDate, DateTime endDate) async {
    try {
      final sleepSessions = await health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.SLEEP_SESSION],
      );

      final List<HealthMetric> processedSleepData = [];
      for (var session in sleepSessions) {
        // Health Connect typically returns SLEEP_SESSION with value as duration in milliseconds
        // Or, it might be a categorical value if not configured to give duration directly.
        // The `value` field for SLEEP_SESSION is often a `HealthDataPointValue` which might be a `NumericHealthValue` or similar.
        // Let's assume value is duration in minutes for simplicity, or we calculate it.
        // The actual structure of `session.value` for SLEEP_SESSION needs to be handled based on how Health Connect provides it.
        // Often, SLEEP_SESSION provides start and end time, and you calculate duration.

        final startTime = session.dateFrom;
        final endTime = session.dateTo;
        final durationInMinutes = endTime.difference(startTime).inMinutes;

        if (durationInMinutes > 0) {
          processedSleepData.add(HealthMetric(
            name: 'Sleep',
            value: durationInMinutes.toDouble(), // Store duration in minutes
            unit: 'min',
            timestamp:
                startTime, // Use start time as the timestamp for the session
          ));
        }
      }
      sleepData.assignAll(processedSleepData);
    } catch (e) {
      // Non-blocking
    }
  }
}
