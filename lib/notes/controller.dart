import 'package:get/get.dart';
import 'database_helper.dart';
import 'note_model.dart';

class NoteController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final RxList<Note> notes = <Note>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  Future<void> loadNotes() async {
    isLoading.value = true;
    notes.value = await _db.getNotes();
    isLoading.value = false;
  }

  Future<void> addNote(Note note) async {
    await _db.insertNote(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await _db.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await _db.deleteNote(id);
    await loadNotes();
  }
}
