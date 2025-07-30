import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

enum SyncStatus { 
  synced, 
  pending, 
  failed, 
  offline 
}

class HybridDatabaseService {
  static final HybridDatabaseService _instance = HybridDatabaseService._internal();
  static HybridDatabaseService get instance => _instance;
  
  HybridDatabaseService._internal();
  
  // Local Database
  static Database? _localDatabase;
  
  // Appwrite
  late Client _client;
  late Databases _databases;
  late Storage _storage;
  
  // Appwrite configuration - Replace with your actual values
// Replace these with your actual values
static const String _endpoint = 'https://cloud.appwrite.io/v1'; // Your Appwrite endpoint
static const String _projectId = '688a7619000cda0a1431'; // Your project ID
static const String _databaseId = '688a9521001b6a913d84'; // Your database ID
static const String _collectionId = '688a957600206fe1a864'; // Your collection ID
static const String _bucketId = '688a970700066cc6686b'; // Your storage bucket ID
  
  bool _isAppwriteInitialized = false;
  bool _isOnline = true;
  
  // Initialize both databases
  Future<void> initialize() async {
    await _initLocalDatabase();
    await _initAppwrite();
  }
  
  // Local Database Setup
  Future<Database> get localDatabase async {
    if (_localDatabase != null) return _localDatabase!;
    _localDatabase = await _initLocalDatabase();
    return _localDatabase!;
  }
  
  Future<Database> _initLocalDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'farahs_hub_notes.db');
    
    return await openDatabase(
      path,
      version: 2, // Increased version for sync fields
      onCreate: _createLocalDB,
      onUpgrade: _upgradeLocalDB,
    );
  }
  
  Future _createLocalDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        createdAt INTEGER,
        updatedAt INTEGER,
        imagePaths TEXT,
        drawingPath TEXT,
        color TEXT,
        appwriteId TEXT,
        syncStatus TEXT DEFAULT 'pending',
        lastSynced INTEGER
      )
    ''');
  }
  
  Future _upgradeLocalDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add sync columns if upgrading from version 1
      await db.execute('ALTER TABLE notes ADD COLUMN appwriteId TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN syncStatus TEXT DEFAULT "pending"');
      await db.execute('ALTER TABLE notes ADD COLUMN lastSynced INTEGER');
    }
  }
  
  // Appwrite Setup
  Future<void> _initAppwrite() async {
    if (_isAppwriteInitialized) return;
    
    try {
      _client = Client()
          .setEndpoint(_endpoint)
          .setProject(_projectId)
          .setSelfSigned(status: true);
      
      _databases = Databases(_client);
      _storage = Storage(_client);
      _isAppwriteInitialized = true;
      _isOnline = true;
    } catch (e) {
      print('Appwrite initialization failed: $e');
      _isOnline = false;
    }
  }
  
  // CRUD Operations (Local First)
  Future<int> insertNote(Note note) async {
    Database db = await localDatabase;
    
    // Insert to local database first
    Map<String, dynamic> noteMap = note.toMap();
    noteMap['syncStatus'] = SyncStatus.pending.toString().split('.').last;
    
    int localId = await db.insert('notes', noteMap);
    
    // Try to sync to Appwrite in background
    _syncNoteToAppwrite(localId);
    
    return localId;
  }
  
  Future<List<Note>> getNotes() async {
    Database db = await localDatabase;
    List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'updatedAt DESC');
    
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
  
  Future<Note?> getNoteById(int id) async {
    Database db = await localDatabase;
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
    Database db = await localDatabase;
    
    Map<String, dynamic> noteMap = note.toMap();
    noteMap['syncStatus'] = SyncStatus.pending.toString().split('.').last;
    noteMap['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    
    int result = await db.update(
      'notes',
      noteMap,
      where: 'id = ?',
      whereArgs: [note.id],
    );
    
    // Try to sync to Appwrite in background
    if (result > 0) {
      _syncNoteToAppwrite(note.id!);
    }
    
    return result;
  }
  
  Future<int> deleteNote(int id) async {
    Database db = await localDatabase;
    
    // Get note data before deletion for Appwrite cleanup
    Note? note = await getNoteById(id);
    
    int result = await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // Try to delete from Appwrite in background
    if (result > 0 && note != null) {
      _deleteNoteFromAppwrite(note);
    }
    
    return result;
  }
  
  // Search functions (local)
  Future<List<Note>> searchNotes(String query) async {
    Database db = await localDatabase;
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
    Database db = await localDatabase;
    
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
  
  // Sync Operations
  Future<void> _syncNoteToAppwrite(int localId) async {
    if (!_isOnline || !_isAppwriteInitialized) return;
    
    try {
      Database db = await localDatabase;
      Note? note = await getNoteById(localId);
      if (note == null) return;
      
      // Upload media files first
      List<String> uploadedImagePaths = [];
      String? uploadedDrawingPath;
      
      // Upload images
      for (String imagePath in note.imagePaths) {
        String? fileId = await _uploadFile(imagePath);
        if (fileId != null) {
          uploadedImagePaths.add(fileId);
        }
      }
      
      // Upload drawing
      if (note.drawingPath != null && note.drawingPath!.isNotEmpty) {
        uploadedDrawingPath = await _uploadFile(note.drawingPath!);
      }
      
      // Create document data
      Map<String, dynamic> documentData = {
        'title': note.title,
        'description': note.description,
        'createdAt': note.createdAt.toIso8601String(),
        'updatedAt': note.updatedAt.toIso8601String(),
        'imagePaths': jsonEncode(uploadedImagePaths),
        'drawingPath': uploadedDrawingPath ?? '',
        'color': note.color,
        'localId': localId.toString(),
      };
      
      // Check if note already exists in Appwrite
      List<Map<String, dynamic>> localNoteData = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [localId],
      );
      
      String? appwriteId = localNoteData.first['appwriteId'];
      
      if (appwriteId != null && appwriteId.isNotEmpty) {
        // Update existing document
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _collectionId,
          documentId: appwriteId,
          data: documentData,
        );
      } else {
        // Create new document
        var document = await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _collectionId,
          documentId: ID.unique(),
          data: documentData,
        );
        
        // Update local record with Appwrite ID
        await db.update(
          'notes',
          {
            'appwriteId': document.$id,
            'syncStatus': SyncStatus.synced.toString().split('.').last,
            'lastSynced': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [localId],
        );
      }
      
    } catch (e) {
      print('Sync to Appwrite failed: $e');
      // Mark as failed in local database
      Database db = await localDatabase;
      await db.update(
        'notes',
        {'syncStatus': SyncStatus.failed.toString().split('.').last},
        where: 'id = ?',
        whereArgs: [localId],
      );
    }
  }
  
  Future<void> _deleteNoteFromAppwrite(Note note) async {
    if (!_isOnline || !_isAppwriteInitialized) return;
    
    try {
      Database db = await localDatabase;
      List<Map<String, dynamic>> noteData = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [note.id],
      );
      
      if (noteData.isNotEmpty) {
        String? appwriteId = noteData.first['appwriteId'];
        if (appwriteId != null && appwriteId.isNotEmpty) {
          await _databases.deleteDocument(
            databaseId: _databaseId,
            collectionId: _collectionId,
            documentId: appwriteId,
          );
        }
      }
    } catch (e) {
      print('Delete from Appwrite failed: $e');
    }
  }
  
  Future<String?> _uploadFile(String filePath) async {
    try {
      File file = File(filePath);
      if (!file.existsSync()) return null;
      
      final inputFile = InputFile.fromPath(path: filePath);
      
      var uploadResult = await _storage.createFile(
        bucketId: _bucketId,
        fileId: ID.unique(),
        file: inputFile,
      );
      
      return uploadResult.$id;
    } catch (e) {
      print('File upload failed: $e');
      return null;
    }
  }
  
  // Backup and Restore Operations
  Future<Map<String, dynamic>> createBackup() async {
    Database db = await localDatabase;
    
    // Get all notes
    List<Map<String, dynamic>> allNotes = await db.query('notes');
    
    // Create backup data structure
    Map<String, dynamic> backupData = {
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
      'notesCount': allNotes.length,
      'notes': allNotes,
    };
    
    return backupData;
  }
  
  Future<String> exportBackupToFile() async {
    try {
      Map<String, dynamic> backupData = await createBackup();
      
      // Get documents directory
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String backupPath = join(documentsDirectory.path, 'notes_backup_$timestamp.json');
      
      // Write backup to file
      File backupFile = File(backupPath);
      await backupFile.writeAsString(jsonEncode(backupData));
      
      return backupPath;
    } catch (e) {
      throw Exception('Backup export failed: $e');
    }
  }
  
  Future<bool> syncAllToAppwrite() async {
    if (!_isOnline || !_isAppwriteInitialized) {
      throw Exception('Cannot sync: No internet connection or Appwrite not available');
    }
    
    try {
      Database db = await localDatabase;
      
      // Get all unsynced notes
      List<Map<String, dynamic>> unsyncedNotes = await db.query(
        'notes',
        where: 'syncStatus = ? OR syncStatus = ?',
        whereArgs: [
          SyncStatus.pending.toString().split('.').last,
          SyncStatus.failed.toString().split('.').last,
        ],
      );
      
      for (Map<String, dynamic> noteData in unsyncedNotes) {
        int localId = noteData['id'];
        await _syncNoteToAppwrite(localId);
      }
      
      return true;
    } catch (e) {
      print('Full sync failed: $e');
      return false;
    }
  }
  
  Future<bool> restoreFromAppwrite() async {
    if (!_isOnline || !_isAppwriteInitialized) {
      throw Exception('Cannot restore: No internet connection or Appwrite not available');
    }
    
    try {
      // Get all documents from Appwrite
      var documentsList = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _collectionId,
      );
      
      Database db = await localDatabase;
      
      for (var document in documentsList.documents) {
        // Check if note already exists locally
        String? localIdStr = document.data['localId'];
        List<Map<String, dynamic>> existingNotes = [];
        
        if (localIdStr != null) {
          existingNotes = await db.query(
            'notes',
            where: 'id = ?',
            whereArgs: [int.parse(localIdStr)],
          );
        }
        
        // Download media files
        List<String> downloadedImagePaths = [];
        String? downloadedDrawingPath;
        
        List<dynamic> imageIds = jsonDecode(document.data['imagePaths'] ?? '[]');
        for (String imageId in imageIds) {
          String? localPath = await _downloadFile(imageId);
          if (localPath != null) {
            downloadedImagePaths.add(localPath);
          }
        }
        
        if (document.data['drawingPath'] != null && document.data['drawingPath'].isNotEmpty) {
          downloadedDrawingPath = await _downloadFile(document.data['drawingPath']);
        }
        
        // Create Note object
        Note note = Note(
          title: document.data['title'],
          description: document.data['description'],
          createdAt: DateTime.parse(document.data['createdAt']),
          updatedAt: DateTime.parse(document.data['updatedAt']),
          imagePaths: downloadedImagePaths,
          drawingPath: downloadedDrawingPath,
          color: document.data['color'],
        );
        
        Map<String, dynamic> noteMap = note.toMap();
        noteMap['appwriteId'] = document.$id;
        noteMap['syncStatus'] = SyncStatus.synced.toString().split('.').last;
        noteMap['lastSynced'] = DateTime.now().millisecondsSinceEpoch;
        
        if (existingNotes.isEmpty) {
          // Insert new note
          await db.insert('notes', noteMap);
        } else {
          // Update existing note
          await db.update(
            'notes',
            noteMap,
            where: 'id = ?',
            whereArgs: [int.parse(localIdStr!)],
          );
        }
      }
      
      return true;
    } catch (e) {
      print('Restore from Appwrite failed: $e');
      return false;
    }
  }
  
  Future<String?> _downloadFile(String fileId) async {
    try {
      var fileData = await _storage.getFileDownload(
        bucketId: _bucketId,
        fileId: fileId,
      );
      
      // Save to local storage
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String localPath = join(documentsDirectory.path, 'downloaded_$fileId');
      
      File localFile = File(localPath);
      await localFile.writeAsBytes(fileData);
      
      return localPath;
    } catch (e) {
      print('File download failed: $e');
      return null;
    }
  }
  
  // Utility methods
  Future<Map<String, int>> getSyncStatus() async {
    Database db = await localDatabase;
    
    int synced = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM notes WHERE syncStatus = ?',
      [SyncStatus.synced.toString().split('.').last]
    )) ?? 0;
    
    int pending = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM notes WHERE syncStatus = ?',
      [SyncStatus.pending.toString().split('.').last]
    )) ?? 0;
    
    int failed = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM notes WHERE syncStatus = ?',
      [SyncStatus.failed.toString().split('.').last]
    )) ?? 0;
    
    return {
      'synced': synced,
      'pending': pending,
      'failed': failed,
      'total': synced + pending + failed,
    };
  }
  
  bool get isOnline => _isOnline;
  
  Future<void> checkConnection() async {
    try {
      await _initAppwrite();
      // Try a simple operation to test connection
      await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _collectionId,
        queries: [Query.limit(1)],
      );
      _isOnline = true;
    } catch (e) {
      _isOnline = false;
    }
  }
  
  // Close database
  Future<void> close() async {
    if (_localDatabase != null) {
      await _localDatabase!.close();
    }
  }
}