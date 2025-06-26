import '../models/note.dart';
import '../services/note_service.dart';

class NoteRepository {
  final NoteService _noteService = NoteService();

  Future<List<Note>> getAllNotes() async {
    return await _noteService.getNotes();
  }

  Future<Note> createNote({
    required String title,
    required String content,
    required String userId,
    double? latitude,
    double? longitude,
    String? imageUrl,
    DateTime? createdAt,
  }) async {
    return await _noteService.createNote(
      title: title,
      content: content,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) async {
    await _noteService.updateNote(
      noteId: noteId,
      title: title,
      content: content,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
    );
  }

  Future<void> deleteNote(String noteId) async {
    await _noteService.deleteNote(noteId);
  }
}
