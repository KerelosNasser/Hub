import 'package:get/get.dart';
import '../models/expense_model.dart';
import '../services/expense_database_service.dart';

class ExpenseController extends GetxController {
  final ExpenseDatabaseService _db = ExpenseDatabaseService();

  final RxList<Expense> expenses = <Expense>[].obs;
  final Rx<Budget?> activeBudget = Rx<Budget?>(null);
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble remainingBudget = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
    loadActiveBudget();
  }

  Future<void> loadExpenses() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _db.getExpenses();
      expenses.assignAll(result);
      _calculateTotals();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading expenses: $e';
      Get.snackbar('Error', 'Failed to load expenses: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onError);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadActiveBudget() async {
    try {
      final budget = await _db.getActiveBudget();
      activeBudget.value = budget;
      _calculateTotals();
    } catch (e) {
      print('Error loading active budget: $e');
    }
  }

  void _calculateTotals() {
    double income = 0.0;
    double expense = 0.0;

    for (var exp in expenses) {
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
    } else {
      remainingBudget.value = 0.0;
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      isLoading.value = true;
      int result = await _db.insertExpense(expense);
      if (result > 0) {
        await loadExpenses();
        Get.snackbar('Success', 'Expense added successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
            colorText: Get.theme.colorScheme.onPrimary);
      } else {
        throw Exception('Failed to add expense');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error adding expense: $e';
      Get.snackbar('Error', 'Failed to add expense: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onError);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      isLoading.value = true;
      int result = await _db.deleteExpense(id);
      if (result > 0) {
        await loadExpenses();
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
      Get.snackbar('Error', 'Failed to delete expense: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onError);
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
        Get.snackbar('Success', 'Budget set successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
            colorText: Get.theme.colorScheme.onPrimary);
      } else {
        throw Exception('Failed to set budget');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to set budget: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onError);
    }
  }

  Future<void> clearAllData() async {
    try {
      isLoading.value = true;
      await _db.clearAllData();
      expenses.clear();
      activeBudget.value = null;
      _calculateTotals();
      Get.snackbar('Success', 'All data cleared successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onPrimary);
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear all data: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onError);
    } finally {
      isLoading.value = false;
    }
  }
}