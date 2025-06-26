import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Note>> getNotes() async {
    final QuerySnapshot snapshot =
        await _firestore
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
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
    final now = createdAt ?? DateTime.now();
    final noteData = {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'userId': userId,
    };

    final docRef = await _firestore.collection('notes').add(noteData);

    return Note(
      id: docRef.id,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      userId: userId,
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
    final now = DateTime.now();
    final noteData = {
      'title': title,
      'content': content,
      'updatedAt': Timestamp.fromDate(now),
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
    };

    await _firestore.collection('notes').doc(noteId).update(noteData);
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }
}
