import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/note_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  
  DatabaseService._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'farahs_hub_notes.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        createdAt INTEGER,
        updatedAt INTEGER,
        imagePaths TEXT,
        drawingPath TEXT,
        color TEXT
      )
    ''');
  }
  
  // CRUD Operations
  Future<int> insertNote(Note note) async {
    Database db = await database;
    return await db.insert('notes', note.toMap());
  }
  
  Future<List<Note>> getNotes() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'updatedAt DESC');
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
  
  Future<Note?> getNoteById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }
  
  Future<int> updateNote(Note note) async {
    Database db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
  
  Future<int> deleteNote(int id) async {
    Database db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Advanced search functions
  Future<List<Note>> searchNotes(String query) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
  
  Future<List<Note>> getNotesByDate(DateTime date) async {
    Database db = await database;
    
    // Convert date to start and end of day timestamps
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    
    List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'createdAt >= ? AND createdAt <= ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      orderBy: 'updatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
  
  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
