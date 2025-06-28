import '../models/note.dart';
import '../repositories/note_repository.dart';
import 'base_viewmodel.dart';

enum ViewMode { list, map }

class HomeViewModel extends BaseViewModel {
  final NoteRepository _noteRepository = NoteRepository();

  List<Note> _notes = [];
  ViewMode _currentViewMode = ViewMode.list;
  String? _currentUserId;

  List<Note> get notes => _notes;
  ViewMode get currentViewMode => _currentViewMode;
  bool get hasNotes => _notes.isNotEmpty;

  List<Note> get notesWithLocation =>
      _notes
          .where((note) => note.latitude != null && note.longitude != null)
          .toList();

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (_currentUserId == null) return;

    await executeAsync(() async {
      _notes = await _noteRepository.getAllNotes(_currentUserId!);
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

  void clearNotes() {
    _notes = [];
    _currentUserId = null;
    notifyListeners();
  }
}
