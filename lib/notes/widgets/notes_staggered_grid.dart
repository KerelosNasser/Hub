import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note_model.dart';
import 'note_grid_item.dart';

class NotesStaggeredGrid extends StatelessWidget {
  final List<Note> notes;
  final Function(Note) onDeleteNote;

  const NotesStaggeredGrid({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: MasonryGridView.builder(
        itemCount: notes.length,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteGridItem(
            note: note,
            onDelete: () => onDeleteNote(note),
          );
        },
      ),
    );
  }
}
