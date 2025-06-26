import 'dart:io';
import '../models/note.dart';
import '../repositories/note_repository.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';
import 'base_viewmodel.dart';

class NoteViewModel extends BaseViewModel {
  final NoteRepository _noteRepository = NoteRepository();
  final LocationService _locationService = LocationService();
  final ImageService _imageService = ImageService();

  Note? _note;
  String _title = '';
  String _content = '';
  String _userId = 'User';
  double? _latitude;
  double? _longitude;
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;

  Note? get note => _note;
  String get title => _title;
  String get content => _content;
  bool get isEditing => _note != null;
  bool get canSave => _title.trim().isNotEmpty && _content.trim().isNotEmpty;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  DateTime get selectedDate => _selectedDate;
  File? get selectedImage => _selectedImage;

  void initialize(Note? note, String userId) {
    _note = note;
    _userId = userId;

    if (note != null) {
      _title = note.title;
      _content = note.content;
      _latitude = note.latitude;
      _longitude = note.longitude;
      _selectedDate = note.createdAt;
    }

    notifyListeners();
  }

  void updateTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void updateContent(String content) {
    _content = content;
    notifyListeners();
  }

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  Future<void> captureLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        notifyListeners();
      }
    } catch (e) {
      _latitude = null;
      _longitude = null;
    }
  }

  Future<bool> saveNote() async {
    if (!canSave) {
      setError('Title and content are required');
      return false;
    }

    return await executeAsync(() async {
      if (isEditing) {
        return await _updateNote();
      } else {
        return await _createNote();
      }
    });
  }

  Future<bool> _createNote() async {
    await captureLocation();

    _note = await _noteRepository.createNote(
      title: _title.trim(),
      content: _content.trim(),
      userId: _userId,
      latitude: _latitude,
      longitude: _longitude,
      createdAt: _selectedDate,
    );
    return true;
  }

  Future<bool> _updateNote() async {
    if (_note == null) return false;

    await _noteRepository.updateNote(
      noteId: _note!.id,
      title: _title.trim(),
      content: _content.trim(),
      latitude: _latitude ?? _note!.latitude,
      longitude: _longitude ?? _note!.longitude,
      imageUrl: _note!.imageUrl,
    );

    _note = _note!.copyWith(
      title: _title.trim(),
      content: _content.trim(),
      updatedAt: DateTime.now(),
      latitude: _latitude ?? _note!.latitude,
      longitude: _longitude ?? _note!.longitude,
    );

    return true;
  }

  Future<bool> deleteNote() async {
    if (_note == null) return false;

    return await executeAsync(() async {
      await _noteRepository.deleteNote(_note!.id);
      return true;
    });
  }

  void reset() {
    _title = '';
    _content = '';
    _note = null;
    _latitude = null;
    _longitude = null;
    _selectedDate = DateTime.now();
    _selectedImage = null;
    clearError();
    setState(ViewState.idle);
  }
}
