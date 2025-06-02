import 'package:get/get.dart';
import '../models/note_model.dart';
import '../services/database_service.dart';

class NoteController extends GetxController {
  final DatabaseService _db = DatabaseService.instance;
  
  // Reactive variables
  final RxList<Note> notes = <Note>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }
  
  // Load all notes from database
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
}
