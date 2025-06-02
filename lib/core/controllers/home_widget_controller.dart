import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farahs_hub/core/services/home_widget_service.dart';
import 'package:intl/intl.dart';

/// Controller to manage home widget updates from the Flutter application
class HomeWidgetController extends GetxController {
  final HomeWidgetService _homeWidgetService = HomeWidgetService();
  
  // Observable values that will be displayed on the widget
  final RxString _title = 'Farah\'s Hub'.obs;
  final RxString _message = 'Tap to open app'.obs;
  final RxString _date = ''.obs;
  
  String get title => _title.value;
  String get message => _message.value;
  String get date => _date.value;
  
  @override
  void onInit() {
    super.onInit();
    initializeWidget();
  }
  
  /// Initialize the widget service and update the widget with current date
  Future<void> initializeWidget() async {
    try {
      await _homeWidgetService.init();
      _updateDate();
      updateWidget();
    } catch (e) {
      debugPrint('Error initializing home widget: $e');
    }
  }
  
  /// Set a custom title for the widget
  void setTitle(String title) {
    _title.value = title;
    updateWidget();
  }
  
  /// Set a custom message for the widget
  void setMessage(String message) {
    _message.value = message;
    updateWidget();
  }
  
  /// Update the date display (defaults to current date)
  void _updateDate() {
    final now = DateTime.now();
    _date.value = DateFormat('MMMM d, yyyy').format(now);
  }
  
  /// Update the widget with current values
  Future<void> updateWidget() async {
    try {
      await _homeWidgetService.updateWidget(
        title: _title.value,
        message: _message.value,
        date: _date.value,
      );
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }
}
