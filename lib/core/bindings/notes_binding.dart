import 'package:farahs_hub/notes/controller.dart';
import 'package:get/get.dart';

class NotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoteController());
  }
}