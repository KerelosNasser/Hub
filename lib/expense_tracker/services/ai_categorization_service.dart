import '../models/expense_model.dart';

class AICategorization {
  
  final Map<String, List<String>> _categoryKeywords = {
    'Food & Dining': ['restaurant', 'cafe', 'food', 'pizza', 'burger', 'coffee', 'lunch', 'dinner', 'breakfast', 'grocery', 'supermarket'],
    'Transportation': ['gas', 'fuel', 'uber', 'taxi', 'bus', 'train', 'parking', 'metro', 'transport'],
    'Shopping': ['store', 'mall', 'amazon', 'shop', 'retail', 'clothing', 'electronics', 'purchase'],
    'Entertainment': ['movie', 'cinema', 'game', 'concert', 'music', 'sports', 'theatre', 'netflix'],
    'Health & Medical': ['hospital', 'doctor', 'pharmacy', 'medical', 'clinic', 'health', 'medicine'],
    'Bills & Utilities': ['electric', 'water', 'internet', 'phone', 'utility', 'bill', 'insurance'],
    'Education': ['school', 'university', 'course', 'book', 'tuition', 'education', 'learning'],
    'Travel': ['hotel', 'flight', 'booking', 'travel', 'vacation', 'trip', 'airbnb'],
    'Personal Care': ['salon', 'beauty', 'cosmetics', 'haircut', 'spa', 'gym', 'fitness'],
  };

  Future<String> categorizeExpense(String title, String description) async {
    final text = '${title.toLowerCase()} ${description.toLowerCase()}';
    
    // Score each category based on keyword matches
    Map<String, double> categoryScores = {};
    
    for (final category in _categoryKeywords.keys) {
      double score = 0.0;
      final keywords = _categoryKeywords[category]!;
      
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          // Give higher score for exact matches in title
          if (title.toLowerCase().contains(keyword)) {
            score += 2.0;
          } else {
            score += 1.0;
          }
        }
      }
      
      if (score > 0) {
        categoryScores[category] = score;
      }
    }
    
    // Return the category with the highest score
    if (categoryScores.isNotEmpty) {
      final bestCategory = categoryScores.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      return bestCategory;
    }
    
    return 'Other';
  }

  Future<List<String>> getSuggestedCategories(List<Expense> expenses) async {
    // Get unique categories from existing expenses
    final existingCategories = expenses
        .map((e) => e.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    
    // Combine with predefined categories
    final allCategories = <String>{
      ...existingCategories,
      ..._categoryKeywords.keys,
    }.toList();
    
    allCategories.sort();
    return allCategories;
  }

  double recommendBudgetAmount(List<Expense> expenses, BudgetPeriod period) {
    if (expenses.isEmpty) return 1000.0; // Default recommendation
    
    // Calculate average spending for the period
    final expensesByPeriod = _groupExpensesByPeriod(expenses, period);
    
    if (expensesByPeriod.isEmpty) return 1000.0;
    
    // Calculate average and add 10% buffer
    final totalSpending = expensesByPeriod.values
        .map((periodExpenses) => periodExpenses
            .where((e) => e.type == ExpenseType.expense)
            .fold(0.0, (sum, e) => sum + e.amount))
        .reduce((a, b) => a + b);
    
    final averageSpending = totalSpending / expensesByPeriod.length;
    return averageSpending * 1.1; // Add 10% buffer
  }

  Map<String, List<Expense>> _groupExpensesByPeriod(List<Expense> expenses, BudgetPeriod period) {
    final Map<String, List<Expense>> grouped = {};
    
    for (final expense in expenses) {
      String key;
      switch (period) {
        case BudgetPeriod.daily:
          key = expense.date.toIso8601String().substring(0, 10);
          break;
        case BudgetPeriod.weekly:
          final weekStart = expense.date.subtract(Duration(days: expense.date.weekday - 1));
          key = weekStart.toIso8601String().substring(0, 10);
          break;
        case BudgetPeriod.monthly:
          key = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
          break;
      }
      
      grouped.putIfAbsent(key, () => []).add(expense);
    }
    
    return grouped;
  }
}