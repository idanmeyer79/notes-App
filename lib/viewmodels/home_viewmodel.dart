import 'package:flutter/material.dart';
import '../models/note.dart';
import '../repositories/note_repository.dart';
import 'base_viewmodel.dart';

enum ViewMode { list, map }

class HomeViewModel extends BaseViewModel {
  final NoteRepository _noteRepository = NoteRepository();

  List<Note> _notes = [];
  ViewMode _currentViewMode = ViewMode.list;
  String _userName = 'User';

  // Getters
  List<Note> get notes => _notes;
  ViewMode get currentViewMode => _currentViewMode;
  String get userName => _userName;
  bool get hasNotes => _notes.isNotEmpty;

  // Notes with location data for map view
  List<Note> get notesWithLocation =>
      _notes
          .where((note) => note.latitude != null && note.longitude != null)
          .toList();

  HomeViewModel() {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    await executeAsync(() async {
      _notes = await _noteRepository.getAllNotes();
    });
  }

  void setViewMode(ViewMode mode) {
    if (_currentViewMode != mode) {
      _currentViewMode = mode;
      notifyListeners();
    }
  }

  Future<void> refreshNotes() async {
    await _loadNotes();
  }

  Future<void> logout() async {
    _notes = [];
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }
}
