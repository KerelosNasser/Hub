import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'health_model.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class HealthController extends GetxController {
  final Health health = Health();

  final RxBool isLoading = true.obs;
  final RxBool hasPermissions = false.obs;
  final RxList<HealthMetric> stepData = <HealthMetric>[].obs;
  final RxList<HealthMetric> heartRateData = <HealthMetric>[].obs;
  final RxList<HealthMetric> caloriesData = <HealthMetric>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeHealthService();
  }

  Future<void> _initializeHealthService() async {
    try {
      // Check if Health Connect is available
      if (Platform.isAndroid) {
        try {
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
                child: Text('Install Health Connect',
                    style: TextStyle(color: Colors.white)),
              ),
            );
            return;
          }
        } catch (e) {
          // Health Connect SDK might not be available on older versions
          print('Health Connect SDK check failed: $e');
          errorMessage.value =
              'Could not verify Health Connect status. Please ensure it is installed and up to date.';
          isLoading.value = false;
          return; // Stop further execution if SDK check fails
        }
      }

      await requestPermissions();
    } catch (e) {
      errorMessage.value = 'Failed to initialize health service: $e';
      isLoading.value = false;
    }
  }

  Future<void> requestPermissions() async {
    try {
      // Request activity recognition permission for steps (required for Android)
      if (Platform.isAndroid) {
        final activityStatus = await Permission.activityRecognition.request();
        if (activityStatus.isDenied) {
          errorMessage.value =
              'Activity recognition permission is required for step counting';
          isLoading.value = false;
          return;
        }
      }

      // Define health data types to request
      final types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.WORKOUT,
      ];

      // Request health permissions
      final permissions = types.map((type) => HealthDataAccess.READ).toList();

      hasPermissions.value = await health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (hasPermissions.value) {
        errorMessage.value = '';
        await fetchHealthData();
      } else {
        isLoading.value = false;
        errorMessage.value =
            'Health permissions are required to access your health data. Please grant permissions in Health Connect app.';

        // Show helpful message for Health Connect
        Get.snackbar(
          'Health Connect Permissions',
          'Open Health Connect app and grant permissions to Farah\'s Hub to view your health data',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () => _openHealthConnect(),
            child: Text('Open Health Connect',
                style: TextStyle(color: Colors.white)),
          ),
        );
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to request health permissions: $e';
      Get.snackbar(
        'Permission Error',
        'Error requesting health permissions. Make sure Health Connect is installed and updated.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> _openHealthConnect() async {
    // Inform the user to open Health Connect manually as direct opening might not be supported
    // or is causing issues with the current package version.
    Get.snackbar(
      'Open Health Connect',
      'Please open the Health Connect app manually from your app drawer to manage permissions.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(
          seconds: 7), // Increased duration for better readability
    );
  }

  Future<void> fetchHealthData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final now = DateTime.now();
      final pastWeek = now.subtract(const Duration(days: 7));

      // Clear existing data
      stepData.clear();
      heartRateData.clear();
      caloriesData.clear();

      // Fetch data concurrently for better performance
      await Future.wait([
        fetchStepsData(pastWeek, now),
        fetchHeartRateData(pastWeek, now),
        fetchCaloriesData(pastWeek, now),
      ]);

      isLoading.value = false;

      // Show success message if data was fetched
      if (stepData.isNotEmpty ||
          heartRateData.isNotEmpty ||
          caloriesData.isNotEmpty) {
        Get.snackbar(
          'Success',
          'Health data updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        errorMessage.value =
            'No health data found for the past 7 days. Make sure you have health data recorded in Health Connect.';
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to fetch health data: $e';
      Get.snackbar(
        'Data Fetch Error',
        'Could not retrieve health data. Please check your Health Connect permissions.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> fetchStepsData(DateTime startDate, DateTime endDate) async {
    try {
      final steps = await health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.STEPS],
      );

      stepData.clear();
      for (var step in steps) {
        stepData.add(HealthMetric(
          name: 'Steps',
          value: double.parse(step.value.toString()),
          unit: 'steps',
          timestamp: step.dateFrom,
        ));
      }
    } catch (e) {
      print('Error fetching steps data: $e');
    }
  }

  Future<void> fetchHeartRateData(DateTime startDate, DateTime endDate) async {
    try {
      final heartRates = await health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.HEART_RATE],
      );

      heartRateData.clear();
      for (var heartRate in heartRates) {
        heartRateData.add(HealthMetric(
          name: 'Heart Rate',
          value: double.parse(heartRate.value.toString()),
          unit: 'bpm',
          timestamp: heartRate.dateFrom,
        ));
      }
    } catch (e) {
      print('Error fetching heart rate data: $e');
    }
  }

  Future<void> fetchCaloriesData(DateTime startDate, DateTime endDate) async {
    try {
      final calories = await health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      caloriesData.clear();
      for (var calorie in calories) {
        caloriesData.add(HealthMetric(
          name: 'Calories',
          value: double.parse(calorie.value.toString()),
          unit: 'kcal',
          timestamp: calorie.dateFrom,
        ));
      }
    } catch (e) {
      print('Error fetching calories data: $e');
    }
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}
