import 'package:farahs_hub/notes/services/hybird_database_service.dart';
import 'package:get/get.dart';
import '../models/note_model.dart';

class NoteController extends GetxController {
  final HybridDatabaseService _db = HybridDatabaseService.instance;
  
  // Reactive variables
  final RxList<Note> notes = <Note>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSyncing = false.obs;
  final RxBool isOnline = true.obs;
  final RxMap<String, int> syncStatus = <String, int>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _db.initialize();
    loadNotes();
    _updateConnectionStatus();
    _updateSyncStatus();
  }
  
  // Load all notes from local database
  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final result = await _db.getNotes();
      notes.assignAll(result);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading notes: $e';
      Get.snackbar('Error', 'Failed to load notes: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Add a new note
  Future<void> addNote(Note note) async {
    try {
      isLoading.value = true;
      int result = await _db.insertNote(note);
      if (result > 0) {
        await loadNotes();
        _updateSyncStatus();
        Get.snackbar('Success', 'Note added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to add note';
        Get.snackbar('Error', 'Failed to add note',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error adding note: $e';
      Get.snackbar('Error', 'Failed to add note: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Update an existing note
  Future<void> updateNote(Note note) async {
    try {
      isLoading.value = true;
      int result = await _db.updateNote(note);
      if (result > 0) {
        await loadNotes();
        _updateSyncStatus();
        Get.snackbar('Success', 'Note updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to update note';
        Get.snackbar('Error', 'Failed to update note',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error updating note: $e';
      Get.snackbar('Error', 'Failed to update note: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Delete a note
  Future<void> deleteNote(int id) async {
    try {
      isLoading.value = true;
      int result = await _db.deleteNote(id);
      if (result > 0) {
        await loadNotes();
        _updateSyncStatus();
        Get.snackbar('Success', 'Note deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to delete note';
        Get.snackbar('Error', 'Failed to delete note',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error deleting note: $e';
      Get.snackbar('Error', 'Failed to delete note: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Get a note by id
  Future<Note?> getNoteById(int id) async {
    try {
      return await _db.getNoteById(id);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error getting note: $e';
      Get.snackbar('Error', 'Failed to get note: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return null;
    }
  }
  
  // Search notes
  Future<List<Note>> searchNotes(String query) async {
    try {
      if (query.isEmpty) {
        return notes;
      }
      
      return await _db.searchNotes(query);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error searching notes: $e';
      Get.snackbar('Error', 'Failed to search notes: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return [];
    }
  }
  
  // Get notes by date
  Future<List<Note>> getNotesByDate(DateTime date) async {
    try {
      return await _db.getNotesByDate(date);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error getting notes by date: $e';
      Get.snackbar('Error', 'Failed to get notes by date: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return [];
    }
  }
  
  // Sync and Backup Operations
  Future<void> syncAllToCloud() async {
    if (!isOnline.value) {
      Get.snackbar('Offline', 'No internet connection available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.surface,
        colorText: Get.theme.colorScheme.onSurface,
      );
      return;
    }
    
    try {
      isSyncing.value = true;
      
      bool success = await _db.syncAllToAppwrite();
      
      if (success) {
        await _updateSyncStatus();
        Get.snackbar('Success', 'All notes synced to cloud',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        Get.snackbar('Sync Failed', 'Some notes could not be synced',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar('Sync Error', 'Failed to sync notes: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isSyncing.value = false;
    }
  }
  
  Future<void> restoreFromCloud() async {
    if (!isOnline.value) {
      Get.snackbar('Offline', 'No internet connection available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.surface,
        colorText: Get.theme.colorScheme.onSurface,
      );
      return;
    }
    
    try {
      isSyncing.value = true;
      
      bool success = await _db.restoreFromAppwrite();
      
      if (success) {
        await loadNotes();
        await _updateSyncStatus();
        Get.snackbar('Success', 'Notes restored from cloud',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        Get.snackbar('Restore Failed', 'Could not restore notes from cloud',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar('Restore Error', 'Failed to restore notes: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isSyncing.value = false;
    }
  }
  
  Future<void> exportBackup() async {
    try {
      isSyncing.value = true;
      
      String backupPath = await _db.exportBackupToFile();
      
      Get.snackbar('Backup Created', 'Backup saved to: ${backupPath.split('/').last}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar('Backup Failed', 'Could not create backup: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isSyncing.value = false;
    }
  }
  
  Future<void> checkConnectionStatus() async {
    await _db.checkConnection();
    _updateConnectionStatus();
  }
  
  void _updateConnectionStatus() {
    isOnline.value = _db.isOnline;
  }
  
  Future<void> _updateSyncStatus() async {
    try {
      Map<String, int> status = await _db.getSyncStatus();
      syncStatus.assignAll(status);
    } catch (e) {
      print('Error updating sync status: $e');
    }
  }
  
  // Getters for UI
  int get totalNotes => syncStatus['total'] ?? 0;
  int get syncedNotes => syncStatus['synced'] ?? 0;
  int get pendingNotes => syncStatus['pending'] ?? 0;
  int get failedNotes => syncStatus['failed'] ?? 0;
  
  bool get hasUnsyncedNotes => pendingNotes > 0 || failedNotes > 0;
  
  String get syncStatusText {
    if (!isOnline.value) return 'Offline';
    if (isSyncing.value) return 'Syncing...';
    if (hasUnsyncedNotes) return '$pendingNotes pending, $failedNotes failed';
    if (totalNotes == 0) return 'No notes';
    return 'All synced';
  }
}