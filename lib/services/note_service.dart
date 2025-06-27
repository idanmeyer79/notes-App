import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Note>> getNotes(String userId) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('notes')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        throw Exception(
          'Database index required. Please create a composite index for "notes" collection with fields: userId (Ascending) and createdAt (Descending). '
          'Click the link in the error message to create it automatically.',
        );
      }
      throw Exception('Failed to load notes: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load notes: $e');
    }
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
    required String userId,
    double? latitude,
    double? longitude,
    String? imageUrl,
    DateTime? createdAt,
  }) async {
    final now = DateTime.now();
    final noteData = <String, dynamic>{
      'title': title,
      'content': content,
      'updatedAt': Timestamp.fromDate(now),
      'latitude': latitude,
      'longitude': longitude,
    };

    // Handle imageUrl - explicitly set to null if provided as null
    if (imageUrl != null) {
      noteData['imageUrl'] = imageUrl;
    } else {
      noteData['imageUrl'] = null; // Explicitly set to null to remove image
    }

    // Handle createdAt - update if provided
    if (createdAt != null) {
      noteData['createdAt'] = Timestamp.fromDate(createdAt);
    }

    final doc = await _firestore.collection('notes').doc(noteId).get();
    if (doc.exists && doc.data()?['userId'] == userId) {
      await _firestore.collection('notes').doc(noteId).update(noteData);
    }
  }

  Future<void> deleteNote(String noteId, String userId) async {
    final doc = await _firestore.collection('notes').doc(noteId).get();
    if (doc.exists && doc.data()?['userId'] == userId) {
      await _firestore.collection('notes').doc(noteId).delete();
    }
  }
}
