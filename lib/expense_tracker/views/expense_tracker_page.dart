import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/expense_list_item.dart';

class ExpenseTrackerPage extends StatelessWidget {
  final ExpenseController expenseController = Get.put(ExpenseController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade700,
      appBar: AppBar(
        title: Text('Expense Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => expenseController.loadExpenses(),
          ),
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.white),
            onPressed: () => _confirmClearAllData(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => BudgetSummaryCard(
            totalIncome: expenseController.totalIncome.value,
            totalExpenses: expenseController.totalExpenses.value,
            remainingBudget: expenseController.remainingBudget.value,
            budget: expenseController.activeBudget.value,
            onSetBudget: () => _showSetBudgetDialog(context),
          )),
          Expanded(
            child: Obx(() {
              if (expenseController.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: Colors.white));
              }
              if (expenseController.expenses.isEmpty) {
                return Center(
                  child: Text(
                    'No expenses recorded yet. Add one!',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                );
              }
              return ListView.builder(
                itemCount: expenseController.expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenseController.expenses[index];
                  return ExpenseListItem(
                    expense: expense,
                    onDelete: () => expenseController.deleteExpense(expense.id!),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        backgroundColor: Colors.pink.shade700,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    Get.dialog(
      AddExpenseDialog(
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
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context) {
    final TextEditingController budgetNameController = TextEditingController();
    final TextEditingController budgetAmountController = TextEditingController();
    Rx<BudgetPeriod> selectedPeriod = BudgetPeriod.monthly.obs;

    if (expenseController.activeBudget.value != null) {
      budgetNameController.text = expenseController.activeBudget.value!.name;
      budgetAmountController.text = expenseController.activeBudget.value!.amount.toString();
      selectedPeriod.value = expenseController.activeBudget.value!.period;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Set Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: budgetNameController,
              decoration: InputDecoration(labelText: 'Budget Name'),
            ),
            TextField(
              controller: budgetAmountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            Obx(() => DropdownButton<BudgetPeriod>(
              value: selectedPeriod.value,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = budgetNameController.text;
              final amount = double.tryParse(budgetAmountController.text) ?? 0.0;
              if (name.isNotEmpty && amount > 0) {
                expenseController.setBudget(
                  Budget(
                    name: name,
                    amount: amount,
                    period: selectedPeriod.value,
                    startDate: DateTime.now(),
                    endDate: _calculateEndDate(selectedPeriod.value, DateTime.now()),
                    isActive: true,
                    createdAt: DateTime.now(),
                  ),
                );
                Get.back();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
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

  void _confirmClearAllData(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Clear All Data'),
        content: Text('Are you sure you want to delete all expenses and budgets? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              expenseController.clearAllData();
              Get.back();
            },
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}