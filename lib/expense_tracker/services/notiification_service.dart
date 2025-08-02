// Enhanced Notification Service using Awesome Notifications
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Notification channel keys
  static const String _budgetChannelKey = 'budget_alerts';
  static const String _weeklyReportChannelKey = 'weekly_reports';
  static const String _generalChannelKey = 'general_notifications';
  static const String _expenseChannelKey = 'expense_notifications';

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/app_icon', // Your app icon
      [
        // Budget Alerts Channel
        NotificationChannel(
          channelKey: _budgetChannelKey,
          channelName: 'Budget Alerts',
          channelDescription: 'Notifications for budget warnings and alerts',
          defaultColor: Colors.orange,
          ledColor: Colors.orange,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          onlyAlertOnce: false,
          playSound: true,
          criticalAlerts: true,
        ),
        
        // Weekly Reports Channel
        NotificationChannel(
          channelKey: _weeklyReportChannelKey,
          channelName: 'Weekly Reports',
          channelDescription: 'Weekly spending reports and insights',
          defaultColor: Colors.purple,
          ledColor: Colors.purple,
          importance: NotificationImportance.Default,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        
        // General Notifications Channel
        NotificationChannel(
          channelKey: _generalChannelKey,
          channelName: 'General Notifications',
          channelDescription: 'General app notifications and updates',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.Default,
          channelShowBadge: true,
          playSound: true,
        ),
        
        // Expense Notifications Channel
        NotificationChannel(
          channelKey: _expenseChannelKey,
          channelName: 'Expense Notifications',
          channelDescription: 'Notifications for expense additions and updates',
          defaultColor: Colors.green,
          ledColor: Colors.green,
          importance: NotificationImportance.Low,
          channelShowBadge: false,
          playSound: false,
          enableVibration: true,
        ),
      ],
    );

    // Request permissions
    await _requestPermissions();
    
    // Set up notification listeners
    _setupNotificationListeners();
  }

  Future<void> _requestPermissions() async {
    await AwesomeNotifications().requestPermissionToSendNotifications(
      channelKey: _budgetChannelKey,
      permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Sound,
        NotificationPermission.Badge,
        NotificationPermission.Vibration,
        NotificationPermission.Light,
        NotificationPermission.CriticalAlert,
      ],
    );
  }

  void _setupNotificationListeners() {
    // Listen to notification actions
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  // Budget Warning Notifications
  Future<void> showBudgetWarning(double usagePercentage, {
    String? budgetName,
    double? remainingAmount,
    String? period,
  }) async {
    String title;
    String body;
    Color notificationColor;
    NotificationLayout layout = NotificationLayout.Default;
    List<NotificationActionButton> actionButtons = [];

    if (usagePercentage >= 100) {
      title = '🚨 Budget Exceeded!';
      body = budgetName != null 
          ? 'Your "$budgetName" budget has been exceeded by ${(usagePercentage - 100).toStringAsFixed(1)}%'
          : 'You\'ve exceeded your budget by ${(usagePercentage - 100).toStringAsFixed(1)}%';
      notificationColor = Colors.red;
      layout = NotificationLayout.BigText;
      
      actionButtons = [
        NotificationActionButton(
          key: 'VIEW_BUDGET',
          label: 'View Budget',
          actionType: ActionType.Default,
          color: Colors.red,
        ),
        NotificationActionButton(
          key: 'ADJUST_BUDGET',
          label: 'Adjust Budget',
          actionType: ActionType.Default,
          color: Colors.orange,
        ),
      ];
    } else if (usagePercentage >= 90) {
      title = '⚠️ Budget Almost Exceeded';
      body = budgetName != null
          ? 'Your "$budgetName" budget is ${usagePercentage.toStringAsFixed(1)}% used. ${remainingAmount != null ? "Only \$${remainingAmount.toStringAsFixed(2)} remaining." : ""}'
          : 'You\'ve used ${usagePercentage.toStringAsFixed(1)}% of your budget';
      notificationColor = Colors.orange;
      
      actionButtons = [
        NotificationActionButton(
          key: 'VIEW_EXPENSES',
          label: 'View Expenses',
          actionType: ActionType.Default,
          color: Colors.orange,
        ),
      ];
    } else if (usagePercentage >= 80) {
      title = '💡 Budget Alert';
      body = budgetName != null
          ? 'Your "$budgetName" budget is ${usagePercentage.toStringAsFixed(1)}% used. Consider monitoring your spending.'
          : 'You\'ve used ${usagePercentage.toStringAsFixed(1)}% of your budget';
      notificationColor = Colors.amber;
    } else {
      return; // No notification needed
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: _budgetChannelKey,
        title: title,
        body: body,
        bigPicture: 'asset://assets/images/budget_warning.png',
        largeIcon: 'asset://assets/images/app_icon.png',
        notificationLayout: layout,
        color: notificationColor,
        backgroundColor: notificationColor.withOpacity(0.1),
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        fullScreenIntent: usagePercentage >= 100,
        criticalAlert: usagePercentage >= 100,
        customSound: 'resource://raw/budget_alert',
        payload: {
          'type': 'budget_warning',
          'usage_percentage': usagePercentage.toString(),
          'budget_name': budgetName ?? '',
          'remaining_amount': remainingAmount?.toString() ?? '',
        },
      ),
      actionButtons: actionButtons,
    );
  }

  // Weekly Report Notification
  Future<void> showWeeklyReport({
    required double totalExpenses,
    required double totalIncome,
    required double budget,
    required Map<String, double> topCategories,
    String? insightMessage,
  }) async {
    String bodyText = 'This week: Spent \$${totalExpenses.toStringAsFixed(2)}';
    if (totalIncome > 0) {
      bodyText += ', Earned \$${totalIncome.toStringAsFixed(2)}';
    }
    if (budget > 0) {
      double budgetUsage = (totalExpenses / budget) * 100;
      bodyText += ', Budget: ${budgetUsage.toStringAsFixed(1)}% used';
    }

    // Create big text content with category breakdown
    String bigText = bodyText;
    if (topCategories.isNotEmpty) {
      bigText += '\n\nTop spending categories:\n';
      topCategories.entries.take(3).forEach((entry) {
        bigText += '• ${entry.key}: \$${entry.value.toStringAsFixed(2)}\n';
      });
    }
    if (insightMessage != null) {
      bigText += '\n💡 $insightMessage';
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: _weeklyReportChannelKey,
        title: '📊 Weekly Spending Report',
        body: bodyText,
        bigPicture: 'asset://assets/images/weekly_report.png',
        largeIcon: 'asset://assets/images/chart_icon.png',
        notificationLayout: NotificationLayout.BigText,
        color: Colors.purple,
        backgroundColor: Colors.purple.withOpacity(0.1),
        category: NotificationCategory.Status,
        payload: {
          'type': 'weekly_report',
          'total_expenses': totalExpenses.toString(),
          'total_income': totalIncome.toString(),
          'budget': budget.toString(),
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'VIEW_ANALYTICS',
          label: 'View Analytics',
          actionType: ActionType.Default,
          color: Colors.purple,
        ),
        NotificationActionButton(
          key: 'SHARE_REPORT',
          label: 'Share',
          actionType: ActionType.Default,
          color: Colors.blue,
        ),
      ],
    );
  }

  // Expense Addition Confirmation
  Future<void> showExpenseAdded({
    required String title,
    required double amount,
    required String category,
    bool isIncome = false,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: _expenseChannelKey,
        title: isIncome ? '💰 Income Added' : '💳 Expense Added',
        body: '$title - \$${amount.toStringAsFixed(2)} ($category)',
        largeIcon: 'asset://assets/images/expense_icon.png',
        color: isIncome ? Colors.green : Colors.red,
        category: NotificationCategory.Status,
        autoDismissible: true,
        showWhen: true,
        payload: {
          'type': 'expense_added',
          'title': title,
          'amount': amount.toString(),
          'category': category,
          'is_income': isIncome.toString(),
        },
      ),
    );
  }

  // Daily Spending Reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 100,
        channelKey: _generalChannelKey,
        title: '📝 Daily Expense Reminder',
        body: 'Don\'t forget to log your expenses for today!',
        largeIcon: 'asset://assets/images/reminder_icon.png',
        color: Colors.blue,
        category: NotificationCategory.Reminder,
        payload: {
          'type': 'daily_reminder',
        },
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  // Budget Goal Achievement
  Future<void> showBudgetGoalAchieved({
    required String budgetName,
    required double savedAmount,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,
        channelKey: _generalChannelKey,
        title: '🎉 Budget Goal Achieved!',
        body: 'Congratulations! You stayed within your "$budgetName" budget and saved \$${savedAmount.toStringAsFixed(2)}!',
        bigPicture: 'asset://assets/images/celebration.png',
        largeIcon: 'asset://assets/images/trophy_icon.png',
        notificationLayout: NotificationLayout.BigPicture,
        color: Colors.green,
        backgroundColor: Colors.green.withOpacity(0.1),
        category: NotificationCategory.Social,
        customSound: 'resource://raw/success_sound',
        payload: {
          'type': 'goal_achieved',
          'budget_name': budgetName,
          'saved_amount': savedAmount.toString(),
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'SHARE_ACHIEVEMENT',
          label: 'Share Success',
          actionType: ActionType.Default,
          color: Colors.green,
        ),
      ],
    );
  }

  // Receipt Scan Success
  Future<void> showReceiptScanSuccess({
    required String merchantName,
    required double amount,
    required String suggestedCategory,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: _generalChannelKey,
        title: '📸 Receipt Scanned Successfully!',
        body: 'Found: $merchantName - \$${amount.toStringAsFixed(2)}\nSuggested category: $suggestedCategory',
        largeIcon: 'asset://assets/images/receipt_icon.png',
        notificationLayout: NotificationLayout.Default,
        color: Colors.teal,
        category: NotificationCategory.Status,
        autoDismissible: true,
        payload: {
          'type': 'receipt_scan_success',
          'merchant': merchantName,
          'amount': amount.toString(),
          'category': suggestedCategory,
        },
      ),
    );
  }

  // Monthly Budget Summary
  Future<void> showMonthlyBudgetSummary({
    required String month,
    required double totalSpent,
    required double budget,
    required double variance,
    required List<String> insights,
  }) async {
    String body = 'You spent \$${totalSpent.toStringAsFixed(2)} of your \$${budget.toStringAsFixed(2)} budget';
    String bigText = '$body\n\n';
    
    if (variance > 0) {
      bigText += '📈 Over budget by \$${variance.toStringAsFixed(2)}\n\n';
    } else {
      bigText += '💰 Under budget by \$${(-variance).toStringAsFixed(2)}\n\n';
    }
    
    bigText += 'Key insights:\n';
    for (String insight in insights.take(3)) {
      bigText += '• $insight\n';
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 4,
        channelKey: _weeklyReportChannelKey,
        title: '📅 $month Budget Summary',
        body: body,
        largeIcon: 'asset://assets/images/monthly_report.png',
        notificationLayout: NotificationLayout.BigText,
        color: variance > 0 ? Colors.orange : Colors.green,
        category: NotificationCategory.Status,
        payload: {
          'type': 'monthly_summary',
          'month': month,
          'total_spent': totalSpent.toString(),
          'budget': budget.toString(),
          'variance': variance.toString(),
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'VIEW_MONTHLY_REPORT',
          label: 'View Report',
          actionType: ActionType.Default,
          color: Colors.blue,
        ),
        NotificationActionButton(
          key: 'SET_NEXT_BUDGET',
          label: 'Set Next Budget',
          actionType: ActionType.Default,
          color: Colors.green,
        ),
      ],
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Check if notifications are allowed
  Future<bool> isNotificationAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  // Get delivered notifications
  Future<List<NotificationModel>> getDeliveredNotifications() async {
    return await AwesomeNotifications().listScheduledNotifications();
  }

  // Notification action handlers
  static Future<void> _onActionReceivedMethod(ReceivedAction receivedAction) async {
    final payload = receivedAction.payload;
    final actionKey = receivedAction.buttonKeyPressed;

    switch (actionKey) {
      case 'VIEW_BUDGET':
        // Navigate to budget page
        Get.toNamed('/budget');
        break;
      case 'ADJUST_BUDGET':
        // Show budget adjustment dialog
        Get.dialog(
          AlertDialog(
            title: Text('Adjust Budget'),
            content: Text('Would you like to increase your budget or review your spending?'),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
              TextButton(onPressed: () {
                Get.back();
                Get.toNamed('/budget-setup');
              }, child: Text('Adjust Budget')),
            ],
          ),
        );
        break;
      case 'VIEW_EXPENSES':
        // Navigate to expenses list
        Get.toNamed('/expenses');
        break;
      case 'VIEW_ANALYTICS':
        // Show analytics bottom sheet
        Get.toNamed('/analytics');
        break;
      case 'SHARE_REPORT':
        // Share weekly/monthly report
        // TODO: Implement sharing functionality
        break;
      case 'SHARE_ACHIEVEMENT':
        // Share budget achievement
        // TODO: Implement achievement sharing
        break;
      case 'VIEW_MONTHLY_REPORT':
        // Navigate to monthly report
        Get.toNamed('/monthly-report');
        break;
      case 'SET_NEXT_BUDGET':
        // Navigate to budget setup for next month
        Get.toNamed('/budget-setup');
        break;
      default:
        // Handle default notification tap
        if (payload?['type'] != null) {
          _handleNotificationTap(payload!['type']!, payload);
        }
        break;
    }
  }

  static Future<void> _onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Handle notification creation
    print('Notification created: ${receivedNotification.title}');
  }

  static Future<void> _onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Handle notification display
    print('Notification displayed: ${receivedNotification.title}');
  }

  static Future<void> _onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification dismissal
    print('Notification dismissed: ${receivedAction.id}');
  }

  static void _handleNotificationTap(String type, Map<String, String?> payload) {
    switch (type) {
      case 'budget_warning':
        Get.toNamed('/budget');
        break;
      case 'weekly_report':
        Get.toNamed('/analytics');
        break;
      case 'expense_added':
        Get.toNamed('/expenses');
        break;
      case 'daily_reminder':
        Get.toNamed('/add-expense');
        break;
      case 'goal_achieved':
        Get.toNamed('/achievements');
        break;
      case 'receipt_scan_success':
        Get.toNamed('/expenses');
        break;
      case 'monthly_summary':
        Get.toNamed('/monthly-report');
        break;
      default:
        Get.toNamed('/');
        break;
    }
  }

  // Utility method to test notifications
  Future<void> testNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999,
        channelKey: _generalChannelKey,
        title: '🧪 Test Notification',
        body: 'This is a test notification to verify the setup is working correctly.',
        largeIcon: 'asset://assets/images/app_icon.png',
        color: Colors.blue,
        category: NotificationCategory.Status,
      ),
    );
  }
}