import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/expense_model.dart';

class ExpenseDatabaseService {
  static final ExpenseDatabaseService _instance = ExpenseDatabaseService._internal();
  factory ExpenseDatabaseService() => _instance;
  ExpenseDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'expense_tracker.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        is_active INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // Expense CRUD operations
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('expenses', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<int> updateExpense(Expense expense) async {
    Database db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    Database db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Budget CRUD operations
  Future<int> insertBudget(Budget budget) async {
    Database db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<List<Budget>> getBudgets() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('budgets', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  Future<Budget?> getActiveBudget() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );
    return maps.isNotEmpty ? Budget.fromMap(maps.first) : null;
  }

  Future<int> updateBudget(Budget budget) async {
    Database db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    Database db = await database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete('expenses');
    await db.delete('budgets');
  }
}