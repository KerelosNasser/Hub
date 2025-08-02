import 'package:farahs_hub/expense_tracker/widgets/add_expense_dialog.dart';
import 'package:farahs_hub/expense_tracker/widgets/analytic_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';
import '../widgets/floating_action_menu.dart';

class ExpenseTrackerPage extends StatelessWidget {
  final ExpenseController expenseController = Get.put(ExpenseController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade700,
              Colors.pink.shade600,
              Colors.orange.shade400,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Budget Summary with enhanced animations
              Obx(() => SmartBudgetSummaryCard(
                totalIncome: expenseController.totalIncome.value,
                totalExpenses: expenseController.totalExpenses.value,
                remainingBudget: expenseController.remainingBudget.value,
                budget: expenseController.activeBudget.value,
                budgetUsagePercentage: expenseController.budgetUsagePercentage.value,
                shouldShowWarning: expenseController.shouldShowBudgetWarning.value,
                insights: expenseController.budgetInsights,
                onSetBudget: () => _showSmartBudgetDialog(context),
                onViewAnalytics: () => _showAnalyticsSheet(context),
                animationController: expenseController.budgetProgressController,
                screenWidth: screenWidth,
              )),
              // Smart Filters Bar
              Obx(() => SmartFiltersBar(
                selectedTimeFilter: expenseController.selectedTimeFilter.value,
                selectedCategoryFilter: expenseController.selectedCategoryFilter.value,
                availableCategories: expenseController.suggestedCategories,
                onTimeFilterChanged: expenseController.setTimeFilter,
                onCategoryFilterChanged: expenseController.setCategoryFilter,
                screenWidth: screenWidth,
              )),
              
              // Enhanced Expense List with animations
              Expanded(
                child: Obx(() {
                  if (expenseController.isLoading.value) {
                    return _buildLoadingState();
                  }
                  
                  if (expenseController.filteredExpenses.isEmpty) {
                    return _buildEmptyState(context, screenWidth);
                  }
                  
                  return AnimationLimiter(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: 100,
                        left: 8,
                        right: 8,
                        top: 8,
                      ),
                      itemCount: expenseController.filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenseController.filteredExpenses[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: AnimatedExpenseListItem(
                                expense: expense,
                                onDelete: () => _confirmDelete(context, expense),
                                onTap: () => _showExpenseDetails(context, expense),
                                animationDelay: Duration(milliseconds: index * 100),
                                screenWidth: screenWidth,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionMenu(
        onAddExpense: () => _showEnhancedAddExpenseDialog(context),
        onScanReceipt: () => _handleReceiptScan(context),
        isProcessing: expenseController.isProcessingOCR,
        animationController: expenseController.fabAnimationController,
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'SmartExpense',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade700.withOpacity(0.9),
              Colors.pink.shade600.withOpacity(0.9),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.analytics_outlined, color: Colors.white),
          onPressed: () => _showAnalyticsSheet(context),
          tooltip: 'Analytics',
        ),
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => expenseController.loadExpenses(),
          tooltip: 'Refresh',
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuSelection(context, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 8),
                  Text('Export', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 8),
                  Text('Settings', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_forever, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Clear All', style: TextStyle(color: Colors.red, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading expenses...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, double screenWidth) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: screenWidth * 0.2,
              color: Colors.white54,
            ),
            SizedBox(height: 24),
            Text(
              'No expenses yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Start tracking your expenses\nor scan a receipt',
              style: TextStyle(
                color: Colors.white70,
                fontSize: screenWidth * 0.04,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showEnhancedAddExpenseDialog(context),
                  icon: Icon(Icons.add, size: 20),
                  label: Text('Add Expense'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleReceiptScan(context),
                  icon: Icon(Icons.camera_alt, size: 20),
                  label: Text('Scan Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEnhancedAddExpenseDialog(BuildContext context) {
    Get.dialog(
      EnhancedAddExpenseDialog(
        suggestedCategories: expenseController.suggestedCategories,
        onSave: (title, description, amount, type, category, date) {
          expenseController.addExpense(
            Expense(
              title: title,
              description: description,
              amount: amount,
              type: type,
              category: category,
              date: date,
              createdAt: DateTime.now(),
            ),
          );
          Get.back();
        },
        onGetSmartCategory: (title, description) => 
            expenseController.getSmartCategory(title, description),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _handleReceiptScan(BuildContext context) async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Opening camera...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final receiptData = await expenseController.scanReceipt();
      
      // Close loading dialog
      Get.back();
      
      if (receiptData != null) {
        // Pre-fill the add expense dialog with scanned data
        Get.dialog(
          EnhancedAddExpenseDialog(
            suggestedCategories: expenseController.suggestedCategories,
            prefilledData: receiptData,
            onSave: (title, description, amount, type, category, date) {
              expenseController.addExpense(
                Expense(
                  title: title,
                  description: description,
                  amount: amount,
                  type: type,
                  category: category,
                  date: date,
                  createdAt: DateTime.now(),
                ),
              );
              Get.back();
            },
            onGetSmartCategory: (title, description) => 
                expenseController.getSmartCategory(title, description),
          ),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          'Scan Failed',
          'Could not scan receipt. Please try again or add expense manually.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Failed to open camera: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showSmartBudgetDialog(BuildContext context) {
    final TextEditingController budgetNameController = TextEditingController();
    final TextEditingController budgetAmountController = TextEditingController();
    Rx<BudgetPeriod> selectedPeriod = BudgetPeriod.monthly.obs;
    RxBool useAIRecommendations = true.obs;

    if (expenseController.activeBudget.value != null) {
      budgetNameController.text = expenseController.activeBudget.value!.name;
      budgetAmountController.text = expenseController.activeBudget.value!.amount.toString();
      selectedPeriod.value = expenseController.activeBudget.value!.period;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.purple.shade700),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Smart Budget Setup',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: budgetNameController,
                  decoration: InputDecoration(
                    labelText: 'Budget Name',
                    prefixIcon: Icon(Icons.label_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: budgetAmountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<BudgetPeriod>(
                  value: selectedPeriod.value,
                  decoration: InputDecoration(
                    labelText: 'Budget Period',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (BudgetPeriod? newValue) {
                    if (newValue != null) {
                      selectedPeriod.value = newValue;
                    }
                  },
                  items: BudgetPeriod.values.map((BudgetPeriod period) {
                    return DropdownMenuItem<BudgetPeriod>(
                      value: period,
                      child: Text(period.toString().split('.').last.capitalizeFirst!),
                    );
                  }).toList(),
                )),
                SizedBox(height: 16),
                Obx(() => SwitchListTile(
                  title: Text('Use AI Recommendations'),
                  subtitle: Text(
                    'Get budget suggestions based on spending history',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: useAIRecommendations.value,
                  onChanged: (value) => useAIRecommendations.value = value,
                  activeColor: Colors.purple.shade700,
                  contentPadding: EdgeInsets.zero,
                )),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final name = budgetNameController.text;
                          final amount = double.tryParse(budgetAmountController.text) ?? 0.0;
                          if (name.isNotEmpty && amount > 0) {
                            expenseController.createSmartBudget(
                              name: name,
                              amount: amount,
                              period: selectedPeriod.value,
                              useAIRecommendations: useAIRecommendations.value,
                            );
                            Get.back();
                          } else {
                            Get.snackbar('Error', 'Please enter valid budget details');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAnalyticsSheet(BuildContext context) {
    Get.bottomSheet(
      ExpenseAnalyticsSheet(
        categoryAnalytics: expenseController.categoryAnalytics,
        totalExpenses: expenseController.totalExpenses.value,
        totalIncome: expenseController.totalIncome.value,
        budgetInsights: expenseController.budgetInsights,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _confirmDelete(BuildContext context, Expense expense) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Expense',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              expenseController.deleteExpense(expense.id!);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: expense.type == ExpenseType.income 
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      expense.type == ExpenseType.income 
                          ? Icons.arrow_circle_up 
                          : Icons.arrow_circle_down,
                      color: expense.type == ExpenseType.income 
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: expense.type == ExpenseType.income 
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (expense.description.isNotEmpty) ...[
                Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(expense.description),
                SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            expense.category,
                            style: TextStyle(
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(DateFormat('MMM dd, yyyy').format(expense.date)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        // TODO: Implement edit functionality
                      },
                      icon: Icon(Icons.edit, size: 20),
                      label: Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _confirmDelete(context, expense);
                      },
                      icon: Icon(Icons.delete, size: 20),
                      label: Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'export':
        Get.snackbar('Coming Soon', 'Data export will be available soon');
        break;
      case 'settings':
        Get.snackbar('Coming Soon', 'Settings page will be available soon');
        break;
      case 'clear':
        _confirmClearAllData(context);
        break;
    }
  }

  void _confirmClearAllData(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Clear All Data',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete all expenses and budgets? This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              expenseController.clearAllData();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}