import 'dart:convert';

class Expense {
  final int? id;
  final String title;
  final String description;
  final double amount;
  final ExpenseType type; // income or expense
  final String category;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'type': type.toString().split('.').last,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: ExpenseType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ExpenseType.expense,
      ),
      category: map['category'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  Expense copyWith({
    int? id,
    String? title,
    String? description,
    double? amount,
    ExpenseType? type,
    String? category,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum ExpenseType { income, expense }

class Budget {
  final int? id;
  final String name;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  Budget({
    this.id,
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'period': period.toString().split('.').last,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.toString().split('.').last == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date']),
      isActive: map['is_active'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}

enum BudgetPeriod { daily, weekly, monthly }