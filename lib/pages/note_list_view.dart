import 'package:flutter/material.dart';
import 'package:notes_app/widgets/notes/note_card.dart';
import '../models/note.dart';
import '../widgets/empty_state_widget.dart';

class NoteListView extends StatelessWidget {
  final List<Note> notes;
  final VoidCallback? onRefresh;

  const NoteListView({super.key, required this.notes, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.note_add,
        title: 'No notes yet',
        description: 'Tap the + button to create your first note',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(note: note);
        },
      ),
    );
  }
}
