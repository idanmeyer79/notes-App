import '../models/note.dart';
import '../services/note_service.dart';

class NoteRepository {
  final NoteService _noteService = NoteService();

  Future<List<Note>> getAllNotes(String userId) async {
    return await _noteService.getNotes(userId);
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
    required String userId,
    double? latitude,
    double? longitude,
    String? imageUrl,
    DateTime? createdAt,
  }) async {
    await _noteService.updateNote(
      noteId: noteId,
      title: title,
      content: content,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }

  Future<void> deleteNote(String noteId, String userId) async {
    await _noteService.deleteNote(noteId, userId);
  }
}
