import 'package:farahs_hub/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../models/expense_model.dart';
import '../services/expense_database_service.dart';
import '../services/ocr_service.dart';
import '../services/ai_categorization_service.dart';

class ExpenseController extends GetxController with GetTickerProviderStateMixin {
  final ExpenseDatabaseService _db = ExpenseDatabaseService();
  final OCRService _ocrService = OCRService();
  final AICategorization _aiService = AICategorization();
  final NotificationService _notificationService = NotificationService();

  // Existing observables
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxList<Expense> filteredExpenses = <Expense>[].obs;
  final Rx<Budget?> activeBudget = Rx<Budget?>(null);
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble remainingBudget = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // New smart features observables
  final RxList<String> suggestedCategories = <String>[].obs;
  final RxBool isProcessingOCR = false.obs;
  final RxString selectedTimeFilter = 'All'.obs;
  final RxString selectedCategoryFilter = 'All'.obs;
  final RxList<CategorySpending> categoryAnalytics = <CategorySpending>[].obs;
  final RxDouble budgetUsagePercentage = 0.0.obs;
  final RxBool shouldShowBudgetWarning = false.obs;
  final RxList<BudgetInsight> budgetInsights = <BudgetInsight>[].obs;

  // Animation controllers
  late AnimationController cardAnimationController;
  late AnimationController budgetProgressController;
  late AnimationController fabAnimationController;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    loadExpenses();
    loadActiveBudget();
    _initializeSmartFeatures();
  }

  void _initializeAnimations() {
    cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    budgetProgressController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  void _initializeSmartFeatures() {
    // Load suggested categories based on user history
    _loadSuggestedCategories();
    // Setup budget notifications
    _setupBudgetNotifications();
  }

  Future<void> loadExpenses() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _db.getExpenses();
      expenses.assignAll(result);
      _applyFilters();
      _calculateTotals();
      _updateCategoryAnalytics();
      _generateBudgetInsights();
      
      // Trigger card animation
      cardAnimationController.forward();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading expenses: $e';
      _showErrorSnackbar('Failed to load expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadActiveBudget() async {
    try {
      final budget = await _db.getActiveBudget();
      activeBudget.value = budget;
      _calculateTotals();
      _checkBudgetStatus();
      
      // Animate budget progress
      if (budget != null) {
        budgetProgressController.forward();
      }
    } catch (e) {
      print('Error loading active budget: $e');
    }
  }

  void _calculateTotals() {
    double income = 0.0;
    double expense = 0.0;

    for (var exp in filteredExpenses) {
      if (exp.type == ExpenseType.income) {
        income += exp.amount;
      } else {
        expense += exp.amount;
      }
    }
    totalIncome.value = income;
    totalExpenses.value = expense;

    if (activeBudget.value != null) {
      remainingBudget.value = activeBudget.value!.amount - totalExpenses.value;
      budgetUsagePercentage.value = (totalExpenses.value / activeBudget.value!.amount * 100).clamp(0.0, 100.0);
    } else {
      remainingBudget.value = 0.0;
      budgetUsagePercentage.value = 0.0;
    }
  }

  void _checkBudgetStatus() {
    if (activeBudget.value != null && budgetUsagePercentage.value > 80) {
      shouldShowBudgetWarning.value = true;
    } else {
      shouldShowBudgetWarning.value = false;
    }
  }

  // Smart OCR Receipt Scanning
  Future<ExpenseData?> scanReceipt() async {
    try {
      isProcessingOCR.value = true;
      HapticFeedback.lightImpact();
      
      final receiptData = await _ocrService.scanReceipt();
      if (receiptData != null) {
        // Auto-categorize using AI
        final suggestedCategory = await _aiService.categorizeExpense(
          receiptData.title, 
          receiptData.description
        );
        
        HapticFeedback.mediumImpact();
        Get.snackbar(
          'Receipt Scanned!', 
          'Found expense: ${receiptData.title}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.9),
          colorText: Get.theme.colorScheme.onPrimary,
          icon: Icon(Icons.receipt_long, color: Get.theme.colorScheme.onPrimary),
          duration: Duration(seconds: 3),
        );
        
        return receiptData.copyWith(category: suggestedCategory);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to scan receipt: $e');
    } finally {
      isProcessingOCR.value = false;
    }
    return null;
  }

  // Smart Category Suggestions
  Future<void> _loadSuggestedCategories() async {
    final categories = await _aiService.getSuggestedCategories(expenses);
    suggestedCategories.assignAll(categories);
  }

  Future<String> getSmartCategory(String title, String description) async {
    return await _aiService.categorizeExpense(title, description);
  }

  // Advanced Filtering
  void setTimeFilter(String filter) {
    selectedTimeFilter.value = filter;
    _applyFilters();
  }

  void setCategoryFilter(String filter) {
    selectedCategoryFilter.value = filter;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = expenses.toList();

    // Apply time filter
    if (selectedTimeFilter.value != 'All') {
      final now = DateTime.now();
      DateTime startDate;
      
      switch (selectedTimeFilter.value) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'This Week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'Last 3 Months':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        default:
          startDate = DateTime(2000);
      }
      
      filtered = filtered.where((expense) => expense.date.isAfter(startDate)).toList();
    }

    // Apply category filter
    if (selectedCategoryFilter.value != 'All') {
      filtered = filtered.where((expense) => expense.category == selectedCategoryFilter.value).toList();
    }

    filteredExpenses.assignAll(filtered);
  }

  // Analytics and Insights
  void _updateCategoryAnalytics() {
    Map<String, double> categoryTotals = {};
    
    for (var expense in expenses) {
      if (expense.type == ExpenseType.expense) {
        categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
    }
    
    List<CategorySpending> analytics = categoryTotals.entries
        .map((entry) => CategorySpending(
            category: entry.key,
            amount: entry.value,
            percentage: totalExpenses.value > 0 ? (entry.value / totalExpenses.value * 100) : 0,
        ))
        .toList();
    
    analytics.sort((a, b) => b.amount.compareTo(a.amount));
    categoryAnalytics.assignAll(analytics);
  }

  void _generateBudgetInsights() {
    List<BudgetInsight> insights = [];
    
    if (activeBudget.value != null && expenses.isNotEmpty) {
      // Daily spending rate insight
      final daysInPeriod = activeBudget.value!.endDate.difference(activeBudget.value!.startDate).inDays;
      final averageDailySpending = totalExpenses.value / daysInPeriod;
      final budgetDailyLimit = activeBudget.value!.amount / daysInPeriod;
      
      if (averageDailySpending > budgetDailyLimit) {
        insights.add(BudgetInsight(
          type: InsightType.warning,
          title: 'Spending Above Daily Limit',
          description: 'You\'re spending \$${averageDailySpending.toStringAsFixed(2)} per day, but your budget allows \$${budgetDailyLimit.toStringAsFixed(2)}',
          actionSuggestion: 'Consider reducing expenses in ${categoryAnalytics.first.category} category',
        ));
      }
      
      // Category overspending
      if (categoryAnalytics.isNotEmpty) {
        final topCategory = categoryAnalytics.first;
        if (topCategory.percentage > 40) {
          insights.add(BudgetInsight(
            type: InsightType.tip,
            title: 'High Category Spending',
            description: '${topCategory.percentage.toStringAsFixed(1)}% of your budget goes to ${topCategory.category}',
            actionSuggestion: 'Look for alternatives or ways to reduce ${topCategory.category} expenses',
          ));
        }
      }
    }
    
    budgetInsights.assignAll(insights);
  }

  // Enhanced expense addition with smart features
  Future<void> addExpenseWithSmartFeatures(Expense expense) async {
    try {
      isLoading.value = true;
      
      // Auto-categorize if no category is provided
      if (expense.category.isEmpty || expense.category == 'Other') {
        final smartCategory = await getSmartCategory(expense.title, expense.description);
        expense = expense.copyWith(category: smartCategory);
      }
      
      int result = await _db.insertExpense(expense);
      if (result > 0) {
        await loadExpenses();
        HapticFeedback.mediumImpact();

        Get.snackbar(
          'Expense Added!', 
          '${expense.title} - \${expense.amount.toStringAsFixed(2)}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.9),
          colorText: Get.theme.colorScheme.onPrimary,
          icon: Icon(Icons.check_circle, color: Get.theme.colorScheme.onPrimary),
          duration: Duration(seconds: 2),
        );
        
        // Check if this triggers budget warning
        _checkBudgetStatus();
      } else {
        throw Exception('Failed to add expense');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error adding expense: $e';
      _showErrorSnackbar('Failed to add expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Smart Budget Management
  Future<void> createSmartBudget({
    required String name,
    required double amount,
    required BudgetPeriod period,
    bool useAIRecommendations = true,
  }) async {
    try {
      if (useAIRecommendations && expenses.isNotEmpty) {
        // Analyze spending patterns and suggest budget adjustments
        final recommendedAmount = _aiService.recommendBudgetAmount(expenses, period);
        if (recommendedAmount != amount) {
          final shouldAdjust = await Get.dialog<bool>(
            AlertDialog(
              title: Text('Budget Recommendation'),
              content: Text('Based on your spending history, we recommend \$${recommendedAmount.toStringAsFixed(2)} for this period. Would you like to use this amount?'),
              actions: [
                TextButton(onPressed: () => Get.back(result: false), child: Text('Keep Original')),
                TextButton(onPressed: () => Get.back(result: true), child: Text('Use Recommendation')),
              ],
            ),
          ) ?? false;
          
          if (shouldAdjust) {
            amount = recommendedAmount;
          }
        }
      }
      
      await setBudget(Budget(
        name: name,
        amount: amount,
        period: period,
        startDate: DateTime.now(),
        endDate: _calculateEndDate(period, DateTime.now()),
        isActive: true,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      _showErrorSnackbar('Failed to create smart budget: $e');
    }
  }

  // Enhanced methods from original controller
  Future<void> addExpense(Expense expense) async {
    await addExpenseWithSmartFeatures(expense);
  }

  Future<void> deleteExpense(int id) async {
    try {
      isLoading.value = true;
      int result = await _db.deleteExpense(id);
      if (result > 0) {
        await loadExpenses();
        HapticFeedback.lightImpact();
        Get.snackbar('Success', 'Expense deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
            colorText: Get.theme.colorScheme.onPrimary);
      } else {
        throw Exception('Failed to delete expense');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error deleting expense: $e';
      _showErrorSnackbar('Failed to delete expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setBudget(Budget budget) async {
    try {
      // Deactivate existing budget if any
      if (activeBudget.value != null) {
        await _db.updateBudget(Budget(
          endDate: DateTime.now(),
          startDate: DateTime.now(),
          id: activeBudget.value!.id,
          amount: activeBudget.value!.amount,
          isActive: false,
          name: activeBudget.value!.name,
          period: activeBudget.value!.period,
          createdAt: activeBudget.value!.createdAt
        ));
      }
      
      // Insert new budget
      int result = await _db.insertBudget(budget);
      if (result > 0) {
        await loadActiveBudget();
        _calculateTotals();
        HapticFeedback.mediumImpact();
        Get.snackbar('Success', 'Budget set successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
            colorText: Get.theme.colorScheme.onPrimary);
      } else {
        throw Exception('Failed to set budget');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to set budget: $e');
    }
  }

  DateTime _calculateEndDate(BudgetPeriod period, DateTime startDate) {
    switch (period) {
      case BudgetPeriod.daily:
        return startDate.add(Duration(days: 1)).subtract(Duration(seconds: 1));
      case BudgetPeriod.weekly:
        return startDate.add(Duration(days: 7)).subtract(Duration(seconds: 1));
      case BudgetPeriod.monthly:
        return DateTime(startDate.year, startDate.month + 1, 1).subtract(Duration(seconds: 1));
    }
  }

  Future<void> clearAllData() async {
    try {
      isLoading.value = true;
      await _db.clearAllData();
      expenses.clear();
      filteredExpenses.clear();
      activeBudget.value = null;
      categoryAnalytics.clear();
      budgetInsights.clear();
      _calculateTotals();
      Get.snackbar('Success', 'All data cleared successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onPrimary);
    } catch (e) {
      _showErrorSnackbar('Failed to clear all data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupBudgetNotifications() {
    // Setup notifications for budget warnings
    _notificationService.init();
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error', 
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
      colorText: Get.theme.colorScheme.onError,
      icon: Icon(Icons.error_outline, color: Get.theme.colorScheme.onError),
    );
  }

  @override
  void onClose() {
    cardAnimationController.dispose();
    budgetProgressController.dispose();
    fabAnimationController.dispose();
    super.onClose();
  }
}

// Supporting models for smart features
class ExpenseData {
  final String title;
  final String description;
  final double amount;
  final String category;
  final DateTime date;

  ExpenseData({
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  ExpenseData copyWith({String? category}) {
    return ExpenseData(
      title: title,
      description: description,
      amount: amount,
      category: category ?? this.category,
      date: date,
    );
  }
}

class CategorySpending {
  final String category;
  final double amount;
  final double percentage;

  CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class BudgetInsight {
  final InsightType type;
  final String title;
  final String description;
  final String actionSuggestion;

  BudgetInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.actionSuggestion,
  });
}

enum InsightType { tip, warning, success }