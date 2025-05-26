import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import 'package:farahs_hub/notes/note_model.dart'; // Assuming Note model is needed here

class DatabaseService extends GetxService {
  static DatabaseService get to => Get.find();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'farah_hub_database.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      // Log the error or show a user-friendly message
      Get.snackbar('Database Error', 'Failed to initialize database: $e');
      // Rethrow the exception if you want to handle it further up the call stack
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            imagePath TEXT,
            drawingPath TEXT,
            createdAt TEXT,
            updatedAt TEXT
          )
          ''');
    } catch (e) {
      Get.snackbar('Database Error', 'Failed to create notes table: $e');
      rethrow;
    }
  }

  // Example: Insert a note
  Future<int> insertNote(Note note) async {
    try {
      final db = await database;
      return await db.insert('notes', note.toMap());
    } catch (e) {
      Get.snackbar('Database Error', 'Failed to insert note: $e');
      return -1; // Or handle error as appropriate
    }
  }

  // Example: Get all notes
  Future<List<Note>> getAllNotes() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('notes');
      return List.generate(maps.length, (i) {
        return Note.fromMap(maps[i]);
      });
    } catch (e) {
      Get.snackbar('Database Error', 'Failed to retrieve notes: $e');
      return []; // Or handle error as appropriate
    }
  }

  // Example: Update a note
  Future<int> updateNote(Note note) async {
    try {
      final db = await database;
      return await db.update(
        'notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
    } catch (e) {
      Get.snackbar('Database Error', 'Failed to update note: $e');
      return -1; // Or handle error as appropriate
    }
  }

  // Example: Delete a note
  Future<int> deleteNote(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      Get.snackbar('Database Error', 'Failed to delete note: $e');
      return -1; // Or handle error as appropriate
    }
  }

  // Close the database when the service is closed
  @override
  void onClose() {
    _database?.close();
    super.onClose();
  }
}
