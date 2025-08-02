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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // Budget Summary with enhanced animations
            Obx(() => AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: SmartBudgetSummaryCard(
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
              ),
            )),
            
            // Smart Filters Bar
            Obx(() => SmartFiltersBar(
              selectedTimeFilter: expenseController.selectedTimeFilter.value,
              selectedCategoryFilter: expenseController.selectedCategoryFilter.value,
              availableCategories: expenseController.suggestedCategories,
              onTimeFilterChanged: expenseController.setTimeFilter,
              onCategoryFilterChanged: expenseController.setCategoryFilter,
            )),
            
            // Enhanced Expense List with animations
            Expanded(
              child: Obx(() {
                if (expenseController.isLoading.value) {
                  return _buildLoadingState();
                }
                
                if (expenseController.filteredExpenses.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                return AnimationLimiter(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 100),
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
          fontSize: 24,
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
          tooltip: 'View Analytics',
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
            PopupMenuItem(value: 'export', child: Row(children: [Icon(Icons.download), SizedBox(width: 8), Text('Export Data')])),
            PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings), SizedBox(width: 8), Text('Settings')])),
            PopupMenuItem(value: 'clear', child: Row(children: [Icon(Icons.delete_forever, color: Colors.red), SizedBox(width: 8), Text('Clear All Data', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ],
    );
  }

  Widget _getBackgroundGradient(BuildContext context) {
    return Container(
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
            'Loading your expenses...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.white54,
          ),
          SizedBox(height: 24),
          Text(
            'No expenses yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start tracking your expenses or scan a receipt',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showEnhancedAddExpenseDialog(context),
                icon: Icon(Icons.add),
                label: Text('Add Expense'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _handleReceiptScan(context),
                icon: Icon(Icons.camera_alt),
                label: Text('Scan Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
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
    final receiptData = await expenseController.scanReceipt();
    
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
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.purple.shade700),
            SizedBox(width: 8),
            Text('Smart Budget Setup'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: budgetNameController,
                decoration: InputDecoration(
                  labelText: 'Budget Name',
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: budgetAmountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                subtitle: Text('Get budget suggestions based on your spending history'),
                value: useAIRecommendations.value,
                onChanged: (value) => useAIRecommendations.value = value,
                activeColor: Colors.purple.shade700,
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
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
            child: Text('Create Budget'),
          ),
        ],
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
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Delete Expense'),
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
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  expense.type == ExpenseType.income 
                      ? Icons.arrow_circle_up 
                      : Icons.arrow_circle_down,
                  color: expense.type == ExpenseType.income 
                      ? Colors.green 
                      : Colors.red,
                  size: 32,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    expense.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '\${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: expense.type == ExpenseType.income 
                        ? Colors.green 
                        : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (expense.description.isNotEmpty) ...[
              Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(expense.description),
              SizedBox(height: 12),
            ],
            Text('Category:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(expense.category),
            SizedBox(height: 12),
            Text('Date:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(DateFormat('MMM dd, yyyy').format(expense.date)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      // TODO: Implement edit functionality
                    },
                    icon: Icon(Icons.edit),
                    label: Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
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
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'export':
        // TODO: Implement data export
        Get.snackbar('Feature Coming Soon', 'Data export will be available in the next update');
        break;
      case 'settings':
        // TODO: Navigate to settings page
        Get.snackbar('Feature Coming Soon', 'Settings page will be available in the next update');
        break;
      case 'clear':
        _confirmClearAllData(context);
        break;
    }
  }

  void _confirmClearAllData(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All Data'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete all expenses and budgets? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
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